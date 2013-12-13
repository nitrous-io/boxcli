require 'spec_helper'

describe Boxcli do
  it 'should have a version number' do
    Boxcli::VERSION.should_not be_nil
  end

  it 'should do something useful' do
    false.should be_true
  end
end
