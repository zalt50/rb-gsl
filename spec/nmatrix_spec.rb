# nmatrix_spec.rb
require "./lib/nmatrix"

describe NMatrix do
  it "correctly fills dense" do
    n = NMatrix.new([4,3], :float64)
    n[0,0] = 14.0
    n[0,1] = 9.0
    n[0,2] = 3.0
    n[1,0] = 2.0
    n[1,1] = 11.0
    n[1,2] = 15.0
    n[2,0] = 0.0
    n[2,1] = 12.0
    n[2,2] = 17.0
    n[3,0] = 5.0
    n[3,1] = 2.0
    n[3,2] = 3.0
  end

  [:float64].each do |dtype|
    it "correctly exposes cblas_xgemm" do
      #STDERR.puts "dtype=#{dtype.to_s}"
      #STDERR.puts "1"
      n = NMatrix.new([4,3], dtype)
      n[0,0] = 14.0
      n[0,1] = 9.0
      n[0,2] = 3.0
      n[1,0] = 2.0
      n[1,1] = 11.0
      n[1,2] = 15.0
      n[2,0] = 0.0
      n[2,1] = 12.0
      n[2,2] = 17.0
      n[3,0] = 5.0
      n[3,1] = 2.0
      n[3,2] = 3.0

      m = NMatrix.new([3,2], dtype)

      m[0,0] = 12.0
      m[0,1] = 25.0
      m[1,0] = 9.0
      m[1,1] = 10.0
      m[2,0] = 8.0
      m[2,1] = 5.0

      #c = NMatrix.new([4,2], dtype)
      r = NMatrix.cblas_gemm(n, m) #, c)
      #c.should equal(r) # check that both are same memory address

      r[0,0].should == 273.0
      r[0,1].should == 455.0
      r[1,0].should == 243.0
      r[1,1].should == 235.0
      r[2,0].should == 244.0
      r[2,1].should == 205.0
      r[3,0].should == 102.0
      r[3,1].should == 160.0
    end
  end

  it "list correctly handles missing initialization value" do
    NMatrix.new(:list, 3, :int8)[0,0].should    == 0
    NMatrix.new(:list, 4, :float64)[0,0].should == 0.0
  end


  ##TODO: Make this test better. It's not nearly exhaustive enough as is.
  it "list correctly handles recursive removal" do
    n = NMatrix.new(:list, [3,3,3], 0)
    n[0,0,0] = 2
    n[1,1,1] = 1
    n[1,0,0] = 3
    n[0,0,1] = 4

    n[0,0,0].should == 2
    n[1,1,1].should == 1
    n[1,0,0].should == 3
    n[0,0,1].should == 4

    n[1,1,1] = 0
    n[0,0,0].should == 2
    n[1,1,1].should == 0
    n[1,0,0].should == 3
    n[0,0,1].should == 4
  end


  it "dense correctly handles missing initialization value" do
    n = NMatrix.new(3, :int8)
    n.stype.should == :dense
    n.dtype.should == :int8

    m = NMatrix.new(4, :float64)
    m.stype.should == :dense
    m.dtype.should == :float64
  end

  [:float64].each do |dtype|
    it "dense correctly handles #{dtype.to_s} multiplication" do
      #STDERR.puts "dtype=#{dtype.to_s}"
      #STDERR.puts "2"
      n = NMatrix.new([4,3], dtype)
      n[0,0] = 14.0
      n[0,1] = 9.0
      n[0,2] = 3.0
      n[1,0] = 2.0
      n[1,1] = 11.0
      n[1,2] = 15.0
      n[2,0] = 0.0
      n[2,1] = 12.0
      n[2,2] = 17.0
      n[3,0] = 5.0
      n[3,1] = 2.0
      n[3,2] = 3.0

      m = NMatrix.new([3,2], dtype)

      m.shape[0].should == 3
      m.shape[1].should == 2
      m.rank.should == 2

      n.shape[0].should == 4
      n.shape[1].should == 3
      n.rank.should == 2

      m[0,0] = 12.0
      m[0,1] = 25.0
      m[1,0] = 9.0
      m[1,1] = 10.0
      m[2,0] = 8.0
      m[2,1] = 5.0

      n.shape[1].should == m.shape[0]

      r = n.multiply(m)

      r[0,0].should == 273.0
      r[0,1].should == 455.0
      r[1,0].should == 243.0
      r[1,1].should == 235.0
      r[2,0].should == 244.0
      r[2,1].should == 205.0
      r[3,0].should == 102.0
      r[3,1].should == 160.0
    end
  end


  [:dense, :list, :yale].each do |storage_type|
    context "(storage: #{storage_type})" do
      it "can be duplicated" do
        n = NMatrix.new(storage_type, [2,3], storage_type == :yale ? :float64 : 1.1)
        n.stype.should equal(storage_type)

        n[0,0] = 0.0
        n[0,1] = 0.1
        n[1,0] = 1.0

        m = n.dup
        m.shape.should == n.shape
        m.rank.should == n.rank
        m.object_id.should_not == n.object_id
        m.stype.should equal(storage_type)
        m[0,0].should == n[0,0]
        m[0,0] = 3.0
        m[0,0].should_not == n[0,0]
      end

      it "enforces shape boundaries" do
        lambda { NMatrix.new(storage_type, [1,10], storage_type == :yale ? :int8 : 0)[-1,0] }.should raise_error
        lambda { NMatrix.new(storage_type, [1,10], storage_type == :yale ? :int8 : 0)[1,0]  }.should raise_error(ArgumentError, "out of range")
        lambda { NMatrix.new(storage_type, [1,10], storage_type == :yale ? :int8 : 0)[0,10] }.should raise_error(ArgumentError, "out of range")
      end

      it "correctly sets and gets" do
        n = NMatrix.new(storage_type, 2, storage_type == :yale ? :int8 : 0)
        (n[0,1] = 1).should == 1
        n[0,0].should == 0
        n[1,0].should == 0
        n[0,1].should == 1
        n[1,1].should == 0
      end
    end

    # dense and list, not yale
    context "(storage: #{storage_type})" do
      it "correctly gets default value" do
        NMatrix.new(storage_type, 3, 0)[1,1].should   == 0
        NMatrix.new(storage_type, 3, 0.1)[1,1].should == 0.1
        NMatrix.new(storage_type, 3, 1)[1,1].should   == 1
      end

      it "returns correct shape and rank" do
        NMatrix.new(storage_type, [3,2,8], 0).shape.should == [3,2,8]
        NMatrix.new(storage_type, [3,2,8], 0).rank.should  == 3
      end
    end unless storage_type == :yale
  end


  it "correctly handles dense construction" do
    NMatrix.new(3,0)[1,1].should == 0
    lambda { NMatrix.new(3,:int8)[1,1] }.should_not raise_error
  end

end