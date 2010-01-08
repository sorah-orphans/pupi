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
    ps.should include('/')
    ps.should include('/hi')
  end

  it 'create page and commit (a)' do
    open("./spec_tmp/a/index.txt","w") do |f|
      f.puts "a - index" 
    end
    @a.add("./spec_tmp/a/index.txt")
    @a.commit("initial commit")
  end

  it 'show source (a /)' do
    @a.show_source("/").should match('a - index')
    @a.show_source("/").should match('a - index')
  end

  it 'show page (a /)' do
    @a.show("/").should match('<p>a - index</p>')
    @a.show("/").should match('<p>a - index</p>')
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
    l[0]["pages"][0].name.should == '/'
    l[0]["name"].should == 'speccer'
    l[1]["revision"].should == 1
    l[1]["comment"].should match('add hi.mkd')
    l[1]["pages"][0].path.should == '/hi'
    l[1]["name"].should == 'speccer'
  end

  it 'pull from another pupi (a -> b)' do
    @b.pull("./spec_tmp/a")
    ps = @b.pages.map{ |p| p.name }
    ps.include('/').should be_true
    ps.include('/hi').should be_true
    File.exist?("./spec_tmp/b/index.txt").should be_true
    File.exist?("./spec_tmp/b/hi.mkd").should be_true
  end

  it 'check log (b)' do
    l = @b.log
    l[0]["revision"].should == 0
    l[0]["comment"].should match('initial commit')
    l[0]["files"][0].name.should == '/'
    l[0]["name"].should == 'speccer'
    l[1]["revision"].should == 1
    l[1]["comment"].should match('add hi.mkd')
    l[1]["pages"][0].path.should == '/hi'
    l[1]["name"].should == 'speccer'
  end

  it 'make another page (b /hey)' do
    open("./spec_tmp/b/hey.html",'w') do |f|
      f.puts "<p>hey</p>"
    end
    @b.add("./spec_tmp/b/hey.html")
    @b.commit("add hey.html")
  end

  it 'add remote pupi' do
    @a.add_remote(
      :name => 'b',
      :path => './spec_tmp/b'
    )
  end

  it 'pull another pupi (b -> a)' do
    @a.pull('b').should == :success
    File.exist?('./spec_tmp/a/hey.html').should be_true
    @a.log[2]["revision"].should == 2
    @a.log[2]["comment"].should == 'add hey.html'
    @a.log[2]["pages"][0].path.should == '/hey.html'
    @a.log[2]["name"].should == 'speccer'
  end

  it 'fix page (a /)' do
    open("./spec_tmp/a/index.txt","w") do |f|
      f.puts "hi. this is a pupi"
    end
    @a.add('./spec_tmp/a/index.txt')
    @a.commit('fix index')
  end

  it 'fix page (b /)' do
    open("./spec_tmp/b/index.txt","a") do |f|
      f.puts "this line is added by b"
    end
    @b.add('./spec_tmp/b/index.txt')
    @a.commit('added line 2')
  end

  it 'pull and merge another pupi (but not conflict) (b -> a)' do
    @a.pull('b').should == :merge_not_conflict
    l = open('./spec_tmp/a/index.txt','r') {|f| f.readlines }
    l[0].should match('hi. this is a pupi')
    l[1].should match('this line is added by b')
  end

  it 'clone another pupi (a -> c)' do
    @c = Pupi.clone("./spec_tmp/a","./spec_tmp/c")
    File.exist?('./spec_tmp/c/index.txt').should be_true
    File.exist?('./spec_tmp/c/hi.mkd').should be_true
    File.exist?('./spec_tmp/c/hey.html').should be_true
    l = @c.log
    l[0]["revision"].should == 0
    l[0]["comment"].should match('initial commit')
    l[0]["files"][0].name.should == '/'
    l[0]["name"].should == 'speccer'
    l[1]["revision"].should == 1
    l[1]["comment"].should match('add hi.mkd')
    l[1]["pages"][0].path.should == '/hi'
    l[1]["name"].should == 'speccer'
    l[2]["revision"].should == 2
    l[2]["comment"].should == 'add hey.html'
    l[2]["pages"][0].path.should == '/hey'
    l[2]["name"].should == 'speccer'
    l[3]["revision"].should == 3
    l[3]["comment"].should == 'fix index'
    l[3]["pages"][0].path.should == '/'
    l[3]["name"].should == 'speccer'
  end

  it 'fix page (c /hi)' do
    open("./spec_tmp/c/hi.mkd","w") do |f|
      f.puts "# hi yey yey yey"
    end
    @c.add("./spec_tmp/c/hi.mkd")
    @c.commit("yey")
  end

  it 'fix page (a /hi)' do
    open("./spec_tmp/a/hi.mkd","w") do |f|
      f.puts "# hi: konnnitiha"
    end
    @c.add("./spec_tmp/a/hi.mkd")
    @c.commit("konnnitiha")
  end

  it 'merge another pupi changes (c -> a)' do 
    @a.pull("./spec_tmp/a").should == :need_merge
    @a.diff("./spec_tmp/a").should be_true
    l = open("./spec_tmp/a/hi.mkd","r") {|f| f.readlines }
    l[0].should match('<<<<<<<')
    l[1].should match('# hi: connnitiha')
    l[2].should match('=======')
    l[3].should match('# hi yey yey yey')
    l[4].should match('>>>>>>>')
    
    open("./spec_tmp/a/hi.mkd","w") do |f|
      f.puts "# hi: connnitiha yey!"
    end

    @a.add("./spec_tmp/a/hi.mkd")
    @a.commit()
  end

  it "fix page (a /)"
  it "fix page (b /)"
  it "merge confict another pupi changes (b -> a)"



  # In future...
  it 'initialize bare pupi'
  it 'push to bare pupi'
  it 'fetch another pupi'

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
