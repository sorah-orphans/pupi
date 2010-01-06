class Pupi
    def initialize(d)
    end

    def self.create(p)
    end

    def commit(p)
    end

    def status()

    class Page
        def initialize(p)
        end

        def self.create(p)
        end

        def save
        end
    end

    class Revision
        def initialize(r)
        end

        def commit(p)
        end

        def add(f)
        end
    end

    class Remote
        def initialize(p)
        end

        def push
        end
        
        def pull
        end

        def merge
            #was done, push to remote.
        end

        def status
        end
    end
end
