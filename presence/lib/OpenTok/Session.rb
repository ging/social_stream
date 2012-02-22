
=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010, TokBox, Inc.

 Date: November 05 14:50:00 2010
=end

module OpenTok

  class Session

    attr_reader :sessionId

    def initialize(sessionId)
      @sessionId     = sessionId
    end

    def to_s
      sessionId
    end

  end

end
