###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech ||{}

	$.cowtech.autocomplete =
		sources: {}

		autoload: (->
			$("[type=\"autocomplete\"]").each(->
				input = $(this)
				id = input.attr("id")

				$.cowtech.autocomplete.sources[id] = input.attr("data-autocomplete-source") if !input.attr("data-autocomplete-source")?

				wrapper = $("<div></div>").attr("style", "display: inline-block; position: relative").attr("data-autocomplete-role", "wrapper")
				input.wrap(wrapper)

				input.autocomplete(
					minLength: 1
					source: ((request, response) ->
						regex = "#{(if input.attr("data-autocomplete-match-beginning") == "true" then "^(" else "(")}#{$.ui.autocomplete.escapeRegex(request.term)})"
						matcher = new RegExp(regex, "i")

						response($.map($.cowtech.autocomplete.sources[id], (text) ->
							if text && (!request.term || matcher.test(text))
								{
									label: text.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(#{$.ui.autocomplete.escapeRegex(request.term)})(?![^<>]*>)(?![^&;]+;)", "gi"), "<strong>$1</strong>")
									value: text
								}
							else
								null
						))
					)
					open: (->
						$("ul.ui-autocomplete.ui-menu").css(s)
					)
				)
				input.data("autocomplete")._renderItem = ((ul, item) ->
					$("<li></li>").data("item.autocomplete", item).append("<a>" + item.label + "</a>").appendTo(ul)
				)
			)
		)
)(jQuery)
