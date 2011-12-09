module OnTheSpot
  module ControllerExtension

    def self.included(base)
      base.extend ClassMethods
    end

    # if this method is called inside a controller, the edit-on-the-spot
    # controller action is added that will allow to edit fields in place
    module ClassMethods
      def can_edit_on_the_spot(check_acces_method=nil)
        define_method :update_attribute_on_the_spot do
          klass, field, id = params[:id].split('__')
          select_data = params[:select_array]
          object = klass.camelize.constantize.find(id)

          is_allowed = check_acces_method.present? ? self.send(check_acces_method, object, field) : true

          if is_allowed
            if object.update_attributes(field => params[:value])
              if select_data.nil?
                render :text => CGI::escapeHTML(object.send(field).to_s)
              else
                parsed_data = JSON.parse(select_data.gsub("'", '"'))
                # render :text => parsed_data[object.send(field).to_s]
                return_value = object.respond_to?("ots_#{field}") ? "ots_#{field}" : field
                render :text => parsed_data[object.send(return_value).to_s]
              end
            else
              render :text => object.errors.full_messages.join("\n"), :status => 422
            end
          else
            render :text => "Acces is not allowed", :status => 422
          end
        end
      end
    end

  end
end