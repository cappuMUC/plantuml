require_dependency 'redmine/wiki_formatting/markdown/helper'

module PlantumlMarkdownHelperPatch
  def self.included(base) # :nodoc:
    base.send(:prepend, HelperMethodsWikiExtensions)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end
end

module HelperMethodsWikiExtensions
  # extend the editor Toolbar for adding a plantuml button
  # overwrite this helper method to have full control about the load order
  def heads_for_wiki_formatter
    return if @heads_for_wiki_plantuml_included
    super
    content_for :header_tags do
        javascript_include_tag('plantuml.js', plugin: 'plantuml') +
        stylesheet_link_tag('plantuml.css', plugin: 'plantuml')
    end
    @heads_for_wiki_plantuml_included = true
  end
end
