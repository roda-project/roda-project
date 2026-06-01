# frozen_string_literal: true

require "tty-file"
require "fileutils"
require "tty-reader"
require "pastel"
require_relative "project/version"
require_relative "project/helpers/ids"
require_relative "project/context"
require_relative "project/helpers/input"
require_relative "project/helpers/template"
require_relative "project/cli"

module Roda
  module Project
    class Error < StandardError; end

    FULLSTACK = 1
    API = 2
    MINIMAL = 3

    SQLITE = 1
    POSTGRESQL = 2
    MYSQL = 3

    RSPEC = 1
    MINITEST = 2

    def self.messages
      [
        ['"What you do today can improve all your tomorrows." - Ralph Marston'],
        ['"What you get by achieving your goals is not as important as what you become by achieving your goals." - Zig Ziglar'],
        ['"Intelligence without ambition is a bird without wings." - Salvador Dali'],
        ['"We may encounter many defeats but we must not be defeated." - May Angelou'],
        ['"A creative man is motivated by the desire to achieve, not by the desire to beat others." - Ayn Rand'],
        ['"A somebody was once a nobody who wanted to and did." - John Burroughs'],
        ['"Courage is the first of human qualities because it is the quality which guarantees all others." - Winston Churchill'],
        ['"The journey of a thousand miles begins with one step." - Lao Tzu'],
        ['"Don’t worry about failures, worry about the chances you miss when you don’t even try." - Jack Canfield'],
        ['"The secret to getting ahead is getting started." - Mark Twain'],
        ['"The power of imagination makes us infinite." - John Muir'],
        ['"Creativity is intelligence having fun." - Albert Einstein'],
        ['"People who are crazy enough to think they can change the world, are the ones who do." - Rob Siltanen'],
        ['"The way to get started is to quit talking and begin doing." - Walt Disney'],
        ['"Success is not final, failure is not fatal: it is the courage to continue that counts." - Winston Churchill'],
        ['"Less is almost always more. Simplicity is almost always the answer." - Zat Rana'],
        ['"It all starts and ends in the mind. The most crucial skill is how you think." - Zat Rana'],
        ['"It is never too late to be what you might have been." - George Eliot'],
        ['"It does not matter how slowly you go, so long as you do not stop." - Confucius'],
        ['"Start where you are. Use what you have. Do what you can." - Arthur Ashe'],
        ['"A goal is a dream with a deadline." - Napoleon Hill'],
        ['"Things do not happen. Things are made to happen." - John F. Kennedy'],
        ['"Quality is not an act, it is a habit." - Aristotle'],
      ]
    end
  end
end
