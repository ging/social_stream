class Site::Current < Site
  class << self
    def instance
      @instance ||=
        first || create!(name: "Social Stream powered site")
    end
  end
end
