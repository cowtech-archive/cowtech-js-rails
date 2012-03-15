###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}

	$.cowtech.calculator =
		root: null
		field: null
		last: null
		result: null
		copy: null
		redo: null

		autoload: ->
			if $("body").is(":not(.embedded)")
				link = $("<a data-calculator-role=\"help\" href=\"#\"></a>").appendTo($("[data-calculator-role=placeholder]"))
				$("<span class=\"c-icon calcolatrice\"></span><span class=\"c-icon-label\">Calcolatrice (#{$.cowtech.accesskeys.mod}Q)</span>").appendTo(link)

				$.cowtech.modal.callbacks.completed.push( ->
					$.cowtech.calculator.setup()
				)

				$.cowtech.modal.setup(link, {
					autoScale: true
					autoDimensions: true
					content: $("[data-calculator-role=template]").html()
					iframe: false
					width: 700
					height: 200
					scrolling: false
				})

				$.cowtech.accesskeys.add_trigger("#calculator-opener", "q", "Apri la calcolatrice", null, true)

		string_to_expr: (num) ->
			num.trim().replace(/,/g, ".").replace(/\s+/g, "")

		format_history: (num) ->
			num.replace(/\./g, ",").replace(/(\+|\*|-|\/)/g, " $1 ")

		compute: ->
			input = $.cowtech.calculator.string_to_expr($.cowtech.calculator.field.val())

			$.cowtech.calculator.field.val("").removeClass("unset error success")
			$.cowtech.calculator.last.removeClass("unset error success")
			$.cowtech.calculator.result.removeClass("unset error success")

			if !$.cowtech.utils.is_blank(input)
				$.cowtech.calculator.last.val($.cowtech.calculator.format_history(input))
				result = null

				if /^([0-9\+\-\*\/\%\^\(\).]+)$/.test(input)
					internal_result = 0.0

					try
						eval("internal_result = 0.0 + (" + input + ")")
						result = internal_result if $.cowtech.utils.is_of_type(internal_result, "number")
					catch e
						result = null

				if !result?
					$.cowtech.calculator.last.addClass("error")
					$.cowtech.calculator.result.addClass("error").val("Calcolo non valido")
				else
					$.cowtech.calculator.result.addClass("success").val(result)
			else
				$.cowtech.calculator.last.val("Nessun calcolo effettuato")
				$.cowtech.calculator.result.val("Nessun calcolo effettuato")

		redo: ->
			$.cowtech.calculator.field.val($.cowtech.calculator.last.val()) if !$.cowtech.calculator.last.is(".unset")
			$.cowtech.calculator.field.focus()

		setup: ->
			$.cowtech.calculator.root = $.cowtech.modal.root.find("[data-calculator-role=root]")
			return if $.cowtech.calculator.root.size() == 0

			$.cowtech.calculator.field = $.cowtech.calculator.root.find("[data-calculator-role=expression]")
			$.cowtech.calculator.last = $.cowtech.calculator.root.find("[data-calculator-role=last]")
			$.cowtech.calculator.result = $.cowtech.calculator.root.find("[data-calculator-role=result]")
			$.cowtech.calculator.copy = $.cowtech.calculator.root.find("[data-calculator-role=copy]")
			$.cowtech.calculator.repeat = $.cowtech.calculator.root.find("[data-calculator-role=repeat]")

			$.cowtech.calculator.field.on("change", (ev) ->
				ev.preventDefault()
				$.cowtech.calculator.compute()
			).on("keypress", (ev) ->
				if ev.keyCode == 13
					ev.preventDefault()
					$.cowtech.calculator.compute()
			)

			$.cowtech.calculator.repeat.on("click", (ev) ->
				$.cowtech.calculator.redo()
				false
			)

			$.cowtech.clipboard.setup($.cowtech.calculator.copy,
				set_text: (client) ->
					text = (if $.cowtech.calculator.result.is(".success") then $.cowtech.calculator.result.val() else " ")
					client.setText(text)
				copied: (client, text) ->
					$.cowtech.messages.alert("success", "Risultato copiato negli appunti.") if !$.cowtech.utils.is_blank(text)
			)
)(jQuery)
