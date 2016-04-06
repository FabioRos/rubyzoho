module CrudMethods

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def first
      r = RubyZoho.configuration.api.first(self.module_name)
      new(r[0])
    end

    def all(last_modified_time = nil) #TODO Refactor into low level API
      max_records = 200
      result = []
      begin
        batch = RubyZoho.configuration.api.some(self.module_name, result.count + 1, max_records, :id, :asc, last_modified_time)
        result.concat(batch) unless batch.nil?
      end until batch.nil? || (batch.length < max_records)
      result.collect { |r| new(r) }
    end

    def find(id)
      self.find_by_id(id)
    end

    def delete(id)
      RubyZoho.configuration.api.delete_record(self.module_name, id)
    end

    def update(object_attribute_hash)
      begin
        raise(RuntimeError, 'No ID found', object_attribute_hash.to_s) if object_attribute_hash[:id].nil?
        id = object_attribute_hash[:id]
        object_attribute_hash.delete(:id)
        r = RubyZoho.configuration.api.update_record(self.module_name, id, object_attribute_hash)
        new(object_attribute_hash.merge!(r)) unless r.nil?


        content_to_log = object_attribute_hash[:email] rescue nil?
        if content_to_log.nil?
          content_to_log ||= object_attribute_hash[:account_name] rescue 'no content'
        end




      rescue SystemCallError => e
        Airbrake.notify(e)
      rescue RuntimeError => e
        puts "AGGIORNAMENTO FALLITO!"
      end

    end

    def update_related(object_attribute_hash)
       begin
        raise(RuntimeError, 'No ID found', object_attribute_hash.to_s) if object_attribute_hash[:id].nil?
        id = object_attribute_hash[:id]
        object_attribute_hash.delete(:id)

        RubyZoho.configuration.api.update_related_records(self.module_name, id, object_attribute_hash)
        find(id)
      rescue SystemCallError => e
        Airbrake.notify(e)
      rescue RuntimeError => e
        puts "AGGIORNAMENTO FALLITO!"
      end
    end

  end

  def attach_file(file_path, file_name)
    RubyZoho.configuration.api.attach_file(self.class.module_name, self.send(primary_key), file_path, file_name)
  end

  def create(object_attribute_hash)
    initialize(object_attribute_hash)
    save
  end

  def save


    content_to_log = 'no content'

    begin
      _h = {}
      @fields.each { |f| _h.merge!({ f => eval("self.#{f.to_s}") })

       }


      _h.delete_if { |k, v| v.nil? }
      r = RubyZoho.configuration.api.add_record(self.class.module_name, _h)
      up_date(r)

    rescue SystemCallError => e
      Airbrake.notify(e)
    rescue RuntimeError => e
      puts "AGGIORNAMENTO FALLITO!"
    end
  end

  def save_object(object)
    begin

      h = {}
    object.fields.each { |f| h.merge!({ f => object.send(f) }) }
    h.delete_if { |k, v| v.nil? }
    r = RubyZoho.configuration.api.add_record(object.module_name, h)
    up_date(r)
    rescue SystemCallError => e
      Airbrake.notify(e)
    rescue RuntimeError => e
      puts "AGGIORNAMENTO FALLITO!"
    end
  end

  def up_date(object_attribute_hash)
    update_or_create_attrs(object_attribute_hash)
    self
  end

end
