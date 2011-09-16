xml.instruct!
xml.XRD :xmlns     => 'http://docs.oasis-open.org/ns/xri/xrd-1.0',
        "xmlns:hm" => 'http://host-meta.net/ns/1.0' do

  xml.tag! "hm:Host", request.host_with_port

  xml.Link :rel      => "lrdd",
           :template => "#{ root_url }subjects/lrdd/{uri}",
           :type     => "application/xrd+xml"

end
