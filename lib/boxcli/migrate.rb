module Boxcli
  # this migrate a box ( either lvm or arya/bran box ) to drogo box 
  class MigrateToDrogo
    def initialize(box)
      @box = box
      @disk = disk
    end

    def run
      return if @box.disk == @disk # already migrated

      # set the box state to migrating
      @box.db_record.update_attribute :state, "migrating"
      # stop the container if running
      @box.stop
      # umount all legacy path of the container
      umount_legacy
      # new destination of container data
      destination_delta_path = "#{@disk}/#{@box.container_name}_delta"
      system "mkdir -p #{destination_delta_path}"

      # if this is an lvm box, we will create a tmp directory to mount delta
      # data of the user and then sync it over because we cant read data from
      # lvm disk otherwise
      # if this is not an lvm box, then just copy directly from existing delta
      # folder to the new location
      case @box.mount_method
      when "lvm"
        # create a tmp dir so we can mount old data
        tmp_dir = "/tmp/" + SecureRandom.hex
        Dir.mkdir tmp_dir
        # remount delta so we can attempt to rsync
        system "mount -t ext4 /dev/#{@box.volume_group}/#{@box.container_name} #{tmp_dir}"
        system "cp -a #{tmp_dir}/. #{destination_delta_path}"
        system "umount #{tmp_dir}"
        Dir.delete tmp_dir
      when "aufs"
        run "cp -a #{@box.delta_folder}/. #{destination_delta_path}"
      end

      # remove sys_boot in lxc config
      config_path = "#{destination_delta_path}/config"
      # backup the config first
      `cp #{config_path} #{config_path}.bk`
      # remove sys_boot in place
      run "sed -i \"s/sys_boot sys_module/sys_module/g\" #{config_path}"

      @box.disk = @disk
      @box.mount = "aufs"
      @box.quotaMethod = "usrquota"
      @box.save
      @box.enforce_usrquota

      # update version on rails
      @box.db_record.update_attributes state: "stopped", version: "drogo"
    end

    def umount_legacy
      system "umount /var/lib/lxc/#{@box.container_name}"
      system "umount /var/lib/lxc/#{@box.container_name}_delta"
    end

    def self.migrate(box, disk)
      self.new(box, disk).run
    end
  end
end
