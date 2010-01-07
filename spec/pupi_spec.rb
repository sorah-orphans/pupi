require 'lib/pupi.rb'
require 'tempfile'

describe 'Pupi class' do
  before do
    Dir.mkdir("./spec_tmp")
    Dir.mkdir("./spec_tmp/a")
    Dir.mkdir("./spec_tmp/b")
    Dir.mkdir("./spec_tmp/c")
    @a = Pupi.create('./spec_tmp/a')
    @b = Pupi.create('./spec_tmp/b')
  end

  it 'files and directories is correct' do
    # check @a
    a = './spec_tmp/a/.pupi'
    File.exist?(a               ).should == true
    File.exist?(a + '/render'   ).should == true
    File.exist?(a + '/source'   ).should == true
    File.exist?(a + '/base'     ).should == true
    File.exist?(a + '/files'    ).should == true
    File.exist?(a + '/commits'  ).should == true
    File.exist?(a + '/latest'   ).should == true
    File.exist?(a + '/remotes'  ).should == true
    File.exist?(a + '/commitbox').should == true
    # check @b
    a = './spec_tmp/b/.pupi'
    File.exist?(a               ).should == true
    File.exist?(a + '/render'   ).should == true
    File.exist?(a + '/source'   ).should == true
    File.exist?(a + '/base'     ).should == true
    File.exist?(a + '/files'    ).should == true
    File.exist?(a + '/commits'  ).should == true
    File.exist?(a + '/latest'   ).should == true
    File.exist?(a + '/remotes'  ).should == true
    File.exist?(a + '/commitbox').should == true
  end

  it 'check create page execption' do
    open("./spec_tmp/hey","w") do |f|
      f.puts "hey"
    end
    lambda { @a.add("./spec_tmp/hey") }.should raise_error(ArgumentError)
  end

  it 'create page and commit (a)' do
    open("./spec_tmp/a/index.txt","w") do |f|
      f.puts "a - index" 
    end
    @a.add("./spec_tmp/a/index.txt")
    @a.commit("initial commit")
  end

  it 'show source (a /index)' do
    @a.show_source("/index").chomp.should match('a - index')
  end

  it 'show page (a /index)' do
    @a.show("/index").chomp.should match('<p>a - index</p>')
  end

  it 'create another page and check rendered page' do
  end

  it 'push to another puki' do
  end

  it 'pull from another puki' do
  end

  it 'merge another puki changes' do
  end

  it 'clone another puki' do
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
