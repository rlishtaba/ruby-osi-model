require 'spec_helper'

describe Osi::Model do
  context '#stub' do
    it do
      expect(described_class.constants).to include(:VERSION)
    end
  end
end
