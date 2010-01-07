require 'lib/pupi.rb'
require 'tempfile'

describe 'Pupi class' do
  before do
    Dir.mkdir("./spec_tmp")
    Dir.mkdir("./spec_tmp/a")
    Dir.mkdir("./spec_tmp/b")
    Dir.mkdir("./spec_tmp/c")
    Pupi.set_config do |c|
      c[:name] = "speccer"
    end
    @a = Pupi.create('./spec_tmp/a')
    @b = Pupi.create('./spec_tmp/b')
  end

  it 'files and directories is correct' do
    # check @a
    a = './spec_tmp/a/.pupi'
    File.exist?(a               ).should be_true
    File.exist?(a + '/render'   ).should be_true
    File.exist?(a + '/source'   ).should be_true
    File.exist?(a + '/base'     ).should be_true
    File.exist?(a + '/files'    ).should be_true
    File.exist?(a + '/commits'  ).should be_true
    File.exist?(a + '/latest'   ).should be_true
    File.exist?(a + '/remotes'  ).should be_true
    File.exist?(a + '/commitbox').should be_true
    # check @b
    a = './spec_tmp/b/.pupi'
    File.exist?(a               ).should be_true
    File.exist?(a + '/render'   ).should be_true
    File.exist?(a + '/source'   ).should be_true
    File.exist?(a + '/base'     ).should be_true
    File.exist?(a + '/files'    ).should be_true
    File.exist?(a + '/commits'  ).should be_true
    File.exist?(a + '/latest'   ).should be_true
    File.exist?(a + '/remotes'  ).should be_true
    File.exist?(a + '/commitbox').should be_true
  end

  it 'check create page execption' do
    open("./spec_tmp/hey","w") do |f|
      f.puts "hey"
    end
    lambda { @a.add("./spec_tmp/hey") }.should raise_error(ArgumentError)
  end

  it 'Pupi#pages' do
    ps = @a.pages.map{ |p| p.name }
    ps.include('/index').should be_true
    ps.include('/hi').should be_true
  end

  it 'create page and commit (a)' do
    open("./spec_tmp/a/index.txt","w") do |f|
      f.puts "a - index" 
    end
    @a.add("./spec_tmp/a/index.txt")
    @a.commit("initial commit")
  end

  it 'show source (a /index)' do
    @a.show_source("/index").should match('a - index')
  end

  it 'show page (a /index)' do
    @a.show("/index").should match('<p>a - index</p>')
  end

  it 'create another page (a /hi)' do
    open("./spec_tmp/a/hi.mkd", "w") do |f|
      f.puts "# hi"
      f.puts "\nhi"
    end

    @a.add("./spec_tmp/a/hi.mkd")
    @a.commit("add hi.mkd")
  end

  it 'check log (a)' do
    l = @a.log
    l[0]["revision"].should == 0
    l[0]["comment"].should match('initial commit')
    l[0]["pages"][0].name.should == '/index'
    l[0]["name"].should == 'speccer'
    l[1]["revision"].should == 1
    l[1]["comment"].should match('add hi.mkd')
    l[1]["pages"][0].path.should == '/hi'
    l[1]["name"].should == 'speccer'
  end

  it 'pull from another pupi (a -> b)' do
    @b.pull("./spec_tmp/a")
    ps = @b.pages.map{ |p| p.name }
    ps.include('/index').should be_true
    ps.include('/hi').should be_true
    File.exist?("./spec_tmp/b/index.txt").should be_true
    File.exist?("./spec_tmp/b/hi.mkd").should be_true
  end

  it 'check log (b)' do
    l = @b.log
    l[0]["revision"].should == 0
    l[0]["comment"].should match('initial commit')
    l[0]["files"][0].name.should == '/index'
    l[0]["name"].should == 'speccer'
    l[1]["revision"].should == 1
    l[1]["comment"].should match('add hi.mkd')
    l[1]["pages"][0].path.should == '/hi'
    l[1]["name"].should == 'speccer'
  end

  it 'make another page (b /vi)' do

  end

  it 'push to another pupi' do

  end

  it 'merge another pupi changes' do
  end

  it 'clone another pupi' do
  end

  after do
    # thanks to http://www.namaraii.com/rubytips/?%A5%C7%A5%A3%A5%EC%A5%AF%A5%C8%A5%EA#l2

    l = Dir::glob("./spec_tmp/**/").sort do |a,b|
       b.split('/').size <=> a.split('/').size
    end

    l.each {|d|
      Dir::foreach(d) do |f|
        File::delete(d + f) unless /\.+$/ =~ f
      end

      Dir::rmdir(d)
    }
  end
end
