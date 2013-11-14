# coding: UTF-8

require 'spec_helper'

describe Premailer::Rails::CustomizedPremailer do
  [ :nokogiri, :hpricot ].each do |adapter|
    next if adapter == :hpricot and RUBY_PLATFORM == 'java'

    context "when adapter is #{adapter}" do
      before { allow(Premailer::Adapter).to receive(:use).and_return(adapter) }

      describe '#to_plain_text' do
        it 'should include the text from the HTML part' do
          premailer =
            Premailer::Rails::CustomizedPremailer
              .new(Fixtures::Message::HTML_PART)
          expect(premailer.to_plain_text.gsub(/\s/, ' ').strip).to \
            eq(Fixtures::Message::TEXT_PART.gsub(/\s/, ' ').strip)
        end
      end

      describe '#to_inline_css' do
        let(:regex) { %r{<p style=("|')color: ?red;?\1>} }

        context 'when inline CSS block present' do
          it 'should return the HTML with the CSS inlined' do
            allow(Premailer::Rails::CSSHelper).to \
              receive(:css_for_doc).and_return('p { color: red; }')
            html = Fixtures::Message::HTML_PART
            premailer = Premailer::Rails::CustomizedPremailer.new(html)
            expect(premailer.to_inline_css).to match(regex)
          end
        end

        context 'when CSS is loaded externally' do
          it 'should return the HTML with the CSS inlined' do
            html = Fixtures::Message::HTML_PART_WITH_CSS
            premailer = Premailer::Rails::CustomizedPremailer.new(html)
            expect(premailer.to_inline_css).to match(regex)
          end
        end
      end
    end
  end

  describe '.new' do
    it 'should extract the CSS' do
      expect(Premailer::Rails::CSSHelper).to receive(:css_for_doc)
      Premailer::Rails::CustomizedPremailer.new('some html')
    end

    it 'should pass on the configs' do
      Premailer::Rails.config = { foo: :bar }
      premailer = Premailer::Rails::CustomizedPremailer.new('some html')
      expect(premailer.instance_variable_get(:'@options')[:foo]).to eq(:bar)
    end

    it 'should not allow to override with_html_string' do
      Premailer::Rails.config = { with_html_string: false }
      premailer = Premailer::Rails::CustomizedPremailer.new('some html')
      options = premailer.instance_variable_get(:'@options')
      expect(options[:with_html_string]).to eq(true)
    end
  end
end
