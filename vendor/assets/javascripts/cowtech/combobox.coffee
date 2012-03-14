###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.widget("ui.combobox", {
		_create: ->
			self = this
			select = @element.hide()
			selected = select.children(":selected")
			value = (if selected.val() then selected.text() else "")

			# Modification #1: Wrap in a div
			wrapper = $("<div class=\"input-append ui-combo\"></div>").attr("style", "display: inline-block; position: relative").attr("data-combobox-role", "wrapper")
			select.wrap(wrapper)

			input = $("<input/>").insertAfter(select).val(value).autocomplete(
				delay: 0
				minLength: 0
				source: ((request, response) ->
					regex = "#{if select.attr("data-combobox-match-beginning" == "true") then "^(" else "("}#{$.ui.autocomplete.escapeRegex(request.term)})"
					matcher = new RegExp(regex, "i")

					response select.children("option").map(->
						text = $(this).text()
						if @value && (!request.term || matcher.test(text))
							{
								label: text.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(#{$.ui.autocomplete.escapeRegex(request.term)})(?![^<>]*>)(?![^&;]+;)", "gi"), "<strong>$1</strong>")
								value: text
								option: this
							}
					)
				)
				open: (-> # Modification #2: Positioning fix and style fix
					ul = $("ul.ui-autocomplete.ui-menu")
					ul.css(
						marginTop: "3px"
						width: "#{input.closest("div.ui-combo").width() - 2}px"
						zIndex: ""
					)
				)
				select: ((event, ui) ->
					ui.item.option.selected = true
					self._trigger("selected", event, {
						item: ui.item.option
					})
				)
				change: ((event, ui) ->
					if !ui.item
						matcher = new RegExp("^#{$.ui.autocomplete.escapeRegex($(this).val())}$", "i")
						valid = false

						select.children("option").each(->
							if @value.match(matcher)
								@selected = valid = true
								false
						)

						if !valid
							$(this).val("")
							select.val("")
							return false
				)
			).addClass("ui-widget ui-widget-content ui-corner-left ui-combo")

			# Modification #3: Copy original classes
			input.addClass(select.attr("class"))

			# Modification #4: Add validation tip-field
			input.attr("id", "#{select.attr("id")}_ce")
			select.attr("data-form-validation-msg-target", "##{input.attr("id")}")

			input.data("autocomplete")._renderItem = ((ul, item) ->
				$("<li></li>").data("item.autocomplete", item).append("<a>#{item.label}</a>").appendTo(ul)
			)

			addon = $("<label class=\"add-on\"></label").insertAfter(input)

			$("<button>&nbsp;</button>").attr("tabIndex", -1).attr("title", "Show All Items").appendTo(addon).button(
				icons:
					primary: "c-icon c-icon-32 down"
					text: false
			).removeClass("ui-corner-all").addClass("ui-corner-right ui-button-icon ui-combo").on("click", ->
				if input.autocomplete("widget").is(":visible")
					input.autocomplete("close")
				else
					input.autocomplete("search", "")
					input.focus()
				false
			)
	})

	$.cowtech = $.cowtech || {}
	$.cowtech.combobox =
		autoload: (->
			$("[type=\"combobox\"]").combobox()
		)
)(jQuery)
