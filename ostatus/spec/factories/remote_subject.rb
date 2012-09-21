class << Proudhon::Finger
  def fetch id
    obj = Object.new
    def obj.links
      { updates_from: 'feed' }
    end

    def obj.magic_key
      OpenSSL::PKey::RSA.generate 256
    end

    obj
  end
end

class << Proudhon::Atom
  def from_uri uri
    obj = Object.new

    def obj.subscribe(callback)
      true
    end

    obj
  end
end

RemoteSubject.class_eval do
  def build_webfinger_info
    {
      aliases: [ "http://example.com/#{ webfinger_id.split('@').first }" ]
    }

  end
end

Factory.define :remote_subject do |s|
  s.sequence(:webfinger_id) { |n| "remote_subject-#{ n }@example.com" }
end
