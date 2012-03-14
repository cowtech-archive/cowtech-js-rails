###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.accesskeys =
		registered: null
		mod: (if navigator.appVersion.indexOf("Mac") != -1 then "⌃⌥" else "Alt + ")

		add: (key, description, trigger) ->
			$.cowtech.accesskeys.registered = {}  if !$.cowtech.accesskeys.registered?
			$.cowtech.accesskeys.registered[key.toUpperCase()] = description
			$("<a href=\"#\" accesskey=\"#{key}\"></a>").appendTo($("body")).on "click", (ev) ->
				$(":focus").trigger("blur").trigger("change")
				trigger($(this), ev)
				false

		add_trigger: (element, key, description, the_event, no_label) ->
			return  if $(element).size() == 0
			if no_label == true
				el = $(element)

				if el.size() > 0
					lel = el
					lel = lel.find("span.label") if lel.find("span.label").size() > 0
					label = (if lel.is("input") || lel.is("submit") then lel.val() else lel.html())
					regex = $.ui.autocomplete.escapeRegex(" (#{$.cowtech.accesskeys.mod}@)").replace("@", "[A-Za-z0-9]+")
					label = label.replace(new RegExp(regex), "")
					label += " (#{$.cowtech.accesskeys.mod + key.toUpperCase()})"
					(if lel.is("input") || lel.is("submit") then lel.val(label) else lel.html(label))

			$.cowtech.accesskeys.add(key, description, (sender, ev) ->
				selector = sender.data("accesskeys-element")
				action_event = sender.data("accesskeys-event")
				el = $(selector)

				if $.cowtech.utils.is_blank(action_event)
					el.click()
				else
					el.trigger(action_event)
			).data(
				"accesskeys-element": element
				"accesskeys-event": the_event || ""
			)

		autoload: ->
			if $("body").is(":not(.embedded)")
				setTimeout((->
					if $.cowtech.accesskeys.registered?
						summary = $("[data-accesskeys-role=summary]")
						$.each($.cowtech.accesskeys.registered, (key, desc) ->
							$("<tr><td>" + $.cowtech.accesskeys.mod + key + "</td><td>" + desc + "</td></tr>").appendTo(summary)
						)

						$.cowtech.modal.setup($("[data-accesskeys-role=\"help\"]"),
							autoScale: true
							autoDimensions: true
							iframe: false
							html: $("[data-accesskeys-role=\"template\"]").html()
							width: 800
							height: 800
						)
				), 10)

				link = $("<a data-accesskeys-role=\"help\" href=\"#\"></a>").appendTo($("[data-accesskeys-role=placeholder]"))
				$("<span class=\"c-icon accesskeys\"></span><span class=\"c-icon-label\">Scorciatoie da tastiera (#{$.cowtech.accesskeys.mod}H)</span>").appendTo(link)

				$.cowtech.accesskeys.add_trigger(link, "h", "Visualizza questo aiuto")
				$.cowtech.accesskeys.add_trigger("[data-ui-role=add]", "a", "Aggiungi", null, true)

				if $("[data-ui-role=save]").size() > 0
					$.cowtech.accesskeys.add("s", "Salva modifiche", ->
						submit = $("[data-ui-role=save]")
						form = submit.closest("form")
						if form.is(".to-validate") && !form.data("validator").checkValidity()
							return
						else
							submit.click()
					)

					$("[data-ui-role=save]").each(->
						$(this).val $(this).val() + " (" + $.cowtech.accesskeys.mod + "S)"
					)

				$.cowtech.accesskeys.add_trigger("[data-search-role=search]", "c", "Cerca", null, true)
				$.cowtech.accesskeys.add_trigger("[data-search-role=clear]", "v", "Visualizza tutti", null, true)
				$.cowtech.accesskeys.add_trigger("#select-action-button", "x", "Esegui azione sulle righe selezionate", null, true)
)(jQuery)
