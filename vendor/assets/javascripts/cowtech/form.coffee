###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.form =
		effect: "cowtech"
		date_plugin: "jquery-ui"
		highlight_method: "twitter-bootstrap"
		locale: "en"
		date_format: "mm/dd/yy"
		password_minimum_length: 8
		labels:
			close: "Close"
			today: "Todat"
		validation_messages:
			phone: "Insert a valid phone number (only number, spaces and \"+\")."
			letter: "Insert a single letter."
			number: "Invalid number."
			date: "Invalid date."
			time: "Invalid time"
			vat: "Invalid VAT number."
			cf: "Invalid CF."
			cap: "Invalid CAP."
			password_length: "Password must be at least 8 characters length."
			password_mismatch: "Password don't match."

		highlight_methods:
			qtip:
				show: ((form, errors, event) ->
					$.cowtech.form.highlight_methods["qtip"].hide(form, form.getInputs())

					conf = form.getConf()
					if errors.length > 0
						$("[data-remote]").each(->
							el = $(this)
							original = el.attr("data-remote")
							el.removeAttr("data-remote")
							el.attr("data-remote-disabled", original)
						)

					$.each(errors, (index, error) ->
						$.cowtech.form.highlight_methods["qtip"].show_single($(error.input), error.messages[0])
					)
				)

				hide: ((form, inputs) ->
					$("[data-remote-disabled]").each(->
						el = $(this)
						original = el.attr("data-remote-disabled")
						el.removeAttr("data-remote-disabled")
						el.attr("data-remote", original)
					)

					$(inputs).each(->
						$.cowtech.form.highlight_methods["qtip"].hide_single($(this))
					)
				)

				show_single: ((field, msg) ->
					field = $(field.attr("data-form-validation-msg-target")) if !$.cowtech.utils.is_blank(field.attr("data-form-validation-msg-target"))
					field.addClass("invalid")

					if $.cowtech.utils.is_null(field.data("qtip"))
						field.qtip(
							content:
								text: msg
							position:
								my: "left center"
								at: "right center"
								target: field
								adjust:
									x: 3
							style:
								classes: "ui-tooltip-validation-error"
								tip: true
							show:
								ready: true
							hide:
								event: "change"
						)
				)

				hide_single: ((field) ->
					field = $(field.attr("data-form-validation-msg-target")) if !$.cowtech.utils.is_blank(field.attr("data-form-validation-msg-target"))
					field.removeClass("invalid").qtip("destroy")
				)

			"twitter-bootstrap":
				show: ((form, errors, event) ->
					$.cowtech.form.highlight_methods["twitter-bootstrap"].hide(form, form.getInputs())

					if errors.length > 0
						$("[data-remote]").each(->
							el = $(this)
							original = el.attr("data-remote")
							el.removeAttr("data-remote")
							el.attr("data-remote-disabled", original)
						)
					$.each(errors, (index, error) ->
						console.info(error)
						$.cowtech.form.highlight_methods["twitter-bootstrap"].show_single($(error.input), error.messages[0])
					)

					$(window).scrollTop($(".invalid:first").offset().top - 100) if $(".invalid").size() > 0
				)

				hide: ((form, inputs) ->
					$("[data-remote-disabled]").each(->
						el = $(this)
						original = el.attr("data-remote-disabled")
						el.removeAttr("data-remote-disabled")
						el.attr("data-remote", original)
					)

					$(inputs).each(->
						$.cowtech.form.highlight_methods["twitter-bootstrap"].hide_single($(this))
					)
				)

				show_single: ((field, msg) ->
					field = $(field.attr("data-form-validation-msg-target")) if !$.cowtech.utils.is_blank(field.attr("data-form-validation-msg-target"))
					container = field.closest(".control-group")
					field.addClass("invalid error")
					container.addClass("error")
					container.find("span.help-block.error").remove()
					$("<span class=\"hint help-block error\"><span class=\"c-icon c-icon-16 error\"></span>#{msg}</span>").appendTo(container.find("div.controls"))
				)

				hide_single: ((field) ->
					console.info('h')
					field = $(field.attr("data-form-validation-msg-target")) if !$.cowtech.utils.is_blank(field.attr("data-form-validation-msg-target"))
					container = field.closest(".control-group")
					field.removeClass("invalid error")
					container.removeClass("error")
					container.find("span.help-block.error").remove()
				)

		format_validation: ((type) ->
			rv = {}
			rv[$.cowtech.form.locale] = $.cowtech.form.validation_messages[type]
			rv
		)

		autoload: (->
			$("form[data-form-validate=true]").cowtech_form()
			$("[data-form-role=editor], [data-wysiwyg-role=editor]").cowtech_editor()
		)

		initialize: (->
			$.tools.validator.localize("en", {
				":email": "Insert a valid e-mail."
				"[required]": "This field is required."
			})

			$.datepicker.regional[$.cowtech.form.locale] =
				closeText: $.cowtech.form.close
				prevText: "&larr;"
				nextText: "&rarr;"
				currentText: $.cowtech.form.today
				monthNames: Date.localized_labels.months
				monthNamesShort: Date.localized_labels.monthsShort
				dayNames: Date.localized_labels.days
				dayNamesShort: Date.localized_labels.daysShort
				dayNamesMin: Date.localized_labels.daysMin
				weekHeader: "Sm"
				dateFormat: $.cowtech.form.date_format
				firstDay: 1
				isRTL: false
				showMonthAfterYear: false
				yearSuffix: ""
			$.datepicker.setDefaults($.datepicker.regional[$.cowtech.form.locale])

			$.tools.dateinput.localize($.cowtech.form.locale, {
				months: Date.localized_labels.months.join(",")
				shortMonths: Date.localized_labels.monthsShort.join(",")
				days: Date.localized_labels.days.join(",")
				shortDays: Date.localized_labels.daysShort.join(",")
			})

			$.tools.validator.fn("[type=phone]", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) || /^(((\+|00)\d{1,4}\s?)?(\d{0,4}\s?)?(\d{5,}))?$/i.test(value)) then true else $.cowtech.form.format_validation("phone"))
			)

			$.tools.validator.fn("[type=letter]", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) || /^([a-z])$/i.test(value)) then true else $.cowtech.form.format_validation("letter"))
			)

			$.tools.validator.fn("[type=numeric], .numeric", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) || $.cowtech.numeric.handle(el)) then true else $.cowtech.form.format_validation("number"))
			)

			$.tools.validator.fn("[validate=date]", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) || /^((\d{2})\/(\d{2})\/(\d{2}|\d{4}))$/i.test(value) or /^((\d{2}|\d{4})-(\d{2})-(\d{2}))$/i.test(value)) then true else $.cowtech.form.format_validation("date"))
			)

			$.tools.validator.fn("[validate=time]", (el, value) ->
				if $.cowtech.utils.is_blank(value)
					if /^((\d{2}):(\d{2}):(\d{2}))$/i.test(value)
						if parseInt(RegExp.$2) > 23 || parseInt(RegExp.$3) > 59 || parseInt(RegExp.$4) > 59 then $.cowtech.form.format_validation("time") else true
					else
						$.cowtech.form.format_validation("time")
				else
					true
			)

			$.tools.validator.fn("[validate=partita-iva]", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) or /^([0-9A-Z]{11,17})$/i.test(value)) then true else $.cowtech.form.format_validation("vat"))
			)

			$.tools.validator.fn("[validate=codice-fiscale]", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) or /^([0-9A-Z]{16})$/i.test(value)) then true else $.cowtech.form.format_validation("cf"))
			)

			$.tools.validator.fn("[validate=cap]", (el, value) ->
				(if ($.cowtech.utils.is_blank(value) or /^([0-9]{5})$/i.test(value)) then true else $.cowtech.form.format_validation("cap"))
			)

			$.tools.validator.fn("[type=password]", (el, value) ->
				el = $(el)
				confirm = el.attr("data-form-password-confirm")

				if !$.cowtech.utils.is_blank(value)
					if ! (new RegExp("/^.{#{$.cowtech.form.password_minimum_length},}$/i")).test(value) && !el.hasClass("free")
						return $.cowtech.form.format_validation("password_length")
					else if el.is("[data-form-password-confirmer]")
						cel = $("#" + el.attr("data-form-password-confirmer"))
						if cel.val() == el.val()
							$.cowtech.form.highlight_methods[$.cowtech.form.highlight_method].hide_single(cel)
						else
							return $.cowtech.form.format_validation("password_mismatch")
				true
			)

			$("#calprev").html("&laquo;")
			$("#calnext").html("&raquo;")
			$.tools.validator.addEffect("cowtech", $.cowtech.form.show_errors, $.cowtech.form.hide_errors)
			$(window).data("cowtech-form-initialized", true)
		)

		setup: ((objs) ->
			locale = $.cowtech.utils.initialize($("body").attr("data-locale"), $.cowtech.form.locale)

			objs.validator(
				effect: $.cowtech.form.effect
				lang: locale
				position: "center left"
			)

			objs.find("input, select, textarea").andSelf().attr("novalidate", "novalidate")
		)

		add_availability_validator: ((config) ->
			jQuery(document).ready(($) ->
				$.tools.validator.fn((if (config.selector) then config.selector else "[validate=" + config.field_type + "]"), (el, value) ->
					rv = true
					value = value.trim()

					if value != ""
						request = $.ajax(
							url: config.url
							async: false
							data: $.extend({
								query: value
								id: el.attr("data-form-validation-availability-id")
							}, config.data || {})
							error: (xhr, text, error) ->
								rv = it: config.error_msg
							success: (data, text, xhr) ->
								if data.success
									rv = {it: config.unavailable_msg} if !data.valid
								else
									rv = {it: config.error_msg}
						)
					rv
				)
			)
		)

		show_errors: ((errors, event) ->
			$.cowtech.form.highlight_methods[$.cowtech.form.highlight_method].show(this, errors, event)
		)

		hide_errors: ((inputs) ->
			$.cowtech.form.highlight_methods[$.cowtech.form.highlight_method].hide(this, inputs)
		)

	$.fn.cowtech_date = (->
		return this if $.cowtech.utils.is_mobile()

		$.fn.date = ((value) ->
			rv = null

			switch $.cowtech.form.date_plugin
				when "jquery-tools"
					if $.cowtech.utils.is_blank(value)
						rv = @data("dateinput").getValue()
					else
						@data("dateinput").setValue(value)
				when "jquery-ui"
					if $.cowtech.utils.is_blank(value)
						rv = @datepicker("getDate")
					else
						@datepicker("setDate", value)
			rv
		)

		@each(->
			locale = $.cowtech.utils.initialize($("body").attr("data-locale"), "it")
			el = $(this)
			format = $.cowtech.utils.initialize(el.attr("data-date-format"), (if $.cowtech.form.date_plugin is "jquery-ui" then $.cowtech.form.date_format else "dd/mm/yyyy"))
			root_id = el.attr("id") + "-popup"

			if $.cowtech.form.highlight_method is "twitter-bootstrap" && !el.parent().is("div.input-append")
				div = $("<div class=\"input-append\"></div>")
				label = $("<label class=\"add-on date\"><button disabled=\"true\"><span class=\"c-icon c-icon-16 date\"></span></button></label>")
				label.find("button, span").css("cursor", "auto")
				el.wrap(div)
				el.after(label)
				el.css("width", el.width() - label.width() - 11)

			switch $.cowtech.form.date_plugin
				when "jquery-tools"
					el.dateinput(
						lang: locale
						format: format
						firstDay: 1
						selectors: true
						css:
							root: root_id
						offset: [5, -1]
						yearRange: [-5, 5]
					)
				when "jquery-ui"
					val = el.val()
					val = val.replace(/^((\d{4})-(\d{2})-(\d{2}))(.*)$/, "$4/$3/$2")
					el.val val
					el.datepicker(
						changeMonth: true
						changeYear: true
						dateFormat: format
						showOtherMonths: true
						selectOtherMonths: true
						minDate: "-5y"
						maxDate: "5y"
					)
			$("#" + root_id).addClass("date-popup")
		)
	)

	$.fn.cowtech_form = (->
		$.cowtech.form.initialize() if $(window).data("cowtech-form-initialized") != true
		@each(->
			form = $(this)
			form.find("[type=date], [validate=date]:not([data-form-date-raw])").cowtech_date()
			$.cowtech.form.setup(form)
		)
	)

	$.fn.cowtech_editor = (->
		@each(->
			field = $(this)
			field.on("keydown", (ev) ->
				rv = true
				el = field.get(0)

				keyCode = ev.keyCode || ev.which
				if keyCode == 9
					rv = false
					start = el.selectionStart
					end = el.selectionEnd
					indented = "#{$(this).val().substring(0, start)}\t#{$(this).val().substring(end)}"
					field.val(indented)
					el.selectionStart = el.selectionEnd = start + 1
				rv
			)
		)
	)
)(jQuery)