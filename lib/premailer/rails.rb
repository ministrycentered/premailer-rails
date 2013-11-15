require 'premailer'
require 'action_mailer'

require 'premailer/rails/version'
require 'premailer/rails/css_loaders'
require 'premailer/rails/css_helper'
require 'premailer/rails/customized_premailer'
require 'premailer/rails/hook'
require 'premailer/rails/nokogiri_fix'

class Premailer
  module Rails
    @config = {
      input_encoding:     'UTF-8',
      inputencoding:      'UTF-8',
      generate_text_part: true
    }
    class << self
      attr_accessor :config
    end
  end
end

ActionMailer::Base.register_interceptor(Premailer::Rails::Hook)
