Redmine::Plugin.register :plantuml do
  name 'PlantUML plugin for Redmine'
  author 'Michael Skrynski'
  description 'This is a plugin for Redmine which renders PlantUML diagrams.'
  version '0.5.1'
  url 'https://github.com/dkd/plantuml'

  requires_redmine version: '2.6'..'4.2'

  settings(partial: 'settings/plantuml',
           default: { 'convert_by' => 'server', 'server_url' => 'http://www.plantuml.com', 'plantuml_binary' => '/usr/local/bin', 'cache_seconds' => '0', 'allow_includes' => false })

  Redmine::WikiFormatting::Macros.register do
    desc <<EOF
      Render PlantUML image.
      <pre>
      {{plantuml(png)
      (Bob -> Alice : hello)
      }}
      </pre>

      Available options are:
      ** (png|svg)
EOF
    macro :plantuml do |obj, args, text|
      raise 'No or bad arguments.' if args.size != 1
      frmt = PlantumlHelper.check_format(args.first)
      case Setting.plugin_plantuml['convert_by']
      when 'server'
      raise 'No PlantUML server URL set.' if Setting.plugin_plantuml['server_url'].blank?
        #image tag with encoded diagram data
        image = PlantumlHelper.encode(text)
        image_tag "#{Setting.plugin_plantuml['server_url']}/plantuml/#{frmt[:type]}/#{image}"
      when 'script'
      raise 'No PlantUML binary set.' if Setting.plugin_plantuml['plantuml_binary'].blank?
        image = PlantumlHelper.plantuml(text, args.first)
        image_tag "/plantuml/#{frmt[:type]}/#{image}#{frmt[:ext]}"
      end
    end
  end
end

Rails.configuration.to_prepare do
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks

  unless Redmine::WikiFormatting::Textile::Helper.included_modules.include? PlantumlHelperPatch
    Redmine::WikiFormatting::Textile::Helper.send(:include, PlantumlHelperPatch)
  end
end
