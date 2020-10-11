module Abyme
  class AbymeComponent < ActionView::Base

    def initialize(association:, form:, &block)
      @association = association
      @form = form
      yield(self)
    end
  
    def persisted_records_for(options = {})
      if options[:collection]
        records = options[:collection]
      else
        records = @form.object.send(@association)
      end
  
      if options[:order].present?
        records = records.order(options[:order])
  
        # GET INVALID RECORDS
        invalids = @form.object.send(@association).reject(&:persisted?)
      
        if invalids.any?
          records = records.to_a.concat(invalids)
        end
      end
  
      @form.fields_for @association, records do |f|
        content_tag(:div, class: 'abyme--fields') do
          if options[:partial]
            # render(options[:partial], f: f)
            ApplicationController.render(template: "shared/#{@association.to_s.singularize}_fields", locals: { f: f })
          else
            ApplicationController.render(template: "shared/#{@association.to_s.singularize}_fields", locals: { f: f })
            # render("#{@association.to_s.singularize}_fields", f: f)
          end
        end
      end
    end
    
    def new_records_for(options = {}, &block)
      content_tag(:div, data: { target: 'abyme.associations', model: @association, abyme_position: options[:position] || :end }) do
        content_tag(:template, class: "abyme--#{@association.to_s.singularize}_template", data: { target: 'abyme.template' }) do
          @form.fields_for @association, @association.to_s.classify.constantize.new, child_index: 'NEW_RECORD' do |f|
            content_tag(:div, class: 'abyme--fields') do
              if options[:partial]
                ApplicationController.render(template: "#{options[:partial]}", locals: { f: f })
              else
                ActionView::Template::HTML.new.render("#{@association.to_s.singularize}_fields", f: f)
              end
            end
          end
        end
      end
    end
  
    def add_association(options = {}, &block)
      action = 'click->abyme#add_association'
      create_button(action, options, &block)
    end
  
    def remove_association(options = {}, &block)
      action = 'click->abyme#remove_association'
      create_button(action, options, &block)
    end
  
    private
    
    def create_button(action, options, &block)
      options[:attributes] = {} if options[:attributes].nil?
      options[:tag] = :button if options[:tag].nil?
  
      if block_given?
        concat content_tag(options[:tag], { data: { action: action }}.merge(options[:attributes])) do
          # capture(&block)
          yield
        end
      else
        render content_tag(options[:tag], options[:content], {data: { action: action }}.merge(options[:attributes]))
      end
    end
  
    def formatize(association)
      association.class.name.tableize
    end
  end
end