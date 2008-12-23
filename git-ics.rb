#!/usr/bin/env ruby
# Makes an ical of commits out of a git repository.
# Author:   Sunny Ripert http://sunfox.org
# Licence:  WTFPl http://sam.zoy.org/wtfpl/
# Requires: $ sudo gem install icalendar grit mime-types
# Usage:    $ ruby git-ics.rb git-directory > calendar.ics

require 'rubygems'
require 'icalendar'
require 'grit'

def git_to_ical(dir)
  repo = Grit::Repo.new(dir)
  repo_name = File.basename(File.expand_path(dir).gsub(/\/?\.git/, ''))
  cal = Icalendar::Calendar.new

  repo.commits.each do |commit|
    datetime = DateTime.parse(commit.committed_date.to_s)
    cal.event do
      dtstamp     datetime
      dtstart     datetime
      dtend       datetime
      summary     "#{repo_name}: commit by #{commit.author}"
      description commit.message
      uid         commit.id
      klass       "PUBLIC"
    end
  end

  cal.to_ical
end

if __FILE__ == $0
  dir = ARGV.first || ""
  begin
    puts git_to_ical(dir)
  rescue Grit::NoSuchPathError, Grit::InvalidGitRepositoryError
    abort "#{$0}: #{File.expand_path(dir)} is an invalid git directory\n" + \
          "Usage: #{$0} directory"
  end
end

