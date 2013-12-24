# encoding: UTF-8

include Vorax

describe 'utils' do

  it 'should transform a simple hash' do
    h = {:p1 => nil, :p2 => false}
    th = Utils.transform_hash(h) do |h, k, v|
      if v.nil?
        h[k] = v.to_s
      elsif v.is_a?(TrueClass)
        h[k] = 1
      elsif v.is_a?(FalseClass)
        h[k] = 0
      else
        h[k] = v
      end
    end
    th.should == {:p1 => '', :p2 => 0}
  end

  it 'should transform hash' do
    h = {:p1 => nil, :p2 => {:x => 1, :y => 2}, :p3 => false}
    th = Utils.transform_hash(h, :deep => true) do |h, k, v|
      if v.nil?
        h[k] = v.to_s
      elsif v.is_a?(TrueClass)
        h[k] = 1
      elsif v.is_a?(FalseClass)
        h[k] = 0
      else
        h[k] = v
      end
    end
    th.should == {:p1 => '', :p2 => {:x => 1, :y => 2}, :p3 => 0}
  end

  it 'should transform a hash with an array' do
    h = {:p1 => nil, :args => [{:x => 1, :y => nil}, {:x => true, :y => false}], :p3 => false}
    th = Utils.transform_hash(h, :deep => true) do |h, k, v|
      if v.nil?
        h[k] = v.to_s
      elsif v.is_a?(TrueClass)
        h[k] = 1
      elsif v.is_a?(FalseClass)
        h[k] = 0
      else
        h[k] = v
      end
    end
    th.should == {:p1=>"", :args=>[{:x=>1, :y=>""}, {:x=>1, :y=>0}], :p3=>0}
  end

end
