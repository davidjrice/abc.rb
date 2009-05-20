require File.dirname(__FILE__) + '/spec_helper'

describe Abc do
  
  it "should determine abcm2ps path" do
    Abc.abcm2ps_path.should == "/usr/local/bin/abcm2ps"
  end
  
  it "should determine gs path" do
    Abc.gs_path.should == "/usr/local/bin/gs"
  end
  
  it "should convert 'Kitchen Girl' to png" do
    kitchen_girl = <<-SRC
    M:4/4
    O:I
    R:R

    X:1
    T:Untitled Reel
    C:Trad.
    K:D
    eg|a2ab ageg|agbg agef|g2g2 fgag|f2d2 d2:|\
    ed|cecA B2ed|cAcA E2ed|cecA B2ed|c2A2 A2:|
    K:G
    AB|cdec BcdB|ABAF GFE2|cdec BcdB|c2A2 A2:|

    X:2
    T:Kitchen Girl
    C:Trad.
    K:D
    [c4a4] [B4g4]|efed c2cd|e2f2 gaba|g2e2 e2fg|
    a4 g4|efed cdef|g2d2 efed|c2A2 A4:|
    K:G
    ABcA BAGB|ABAG EDEG|A2AB c2d2|e3f edcB|ABcA BAGB|
    ABAG EGAB|cBAc BAG2|A4 A4:|
    SRC
    
    inputname = "KitchenGirl"
    
    Abc.to_png(inputname, kitchen_girl).should match(/(.*).png(.*)/) #should == "/Users/dave/abc/Out.ps"
  end
end