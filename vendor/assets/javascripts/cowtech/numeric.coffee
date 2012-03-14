###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}

	$.cowtech.numeric =
		precision: 3
		autoload: (->
			$("[type=numeric], [validate=numeric]").cowtech_numeric()
		)

		handle: ((input) ->
			regex =
			float: /^(-?)(\d+)([,.]\d+)?$/
			integer: /^(-?)\d+$/

			is_float = (input.attr("data-numeric-float") == "true")
			positive = (input.attr("data-numeric-positive") == "true")
			not_zero = (input.attr("data-numeric-not-zero") == "true")
			precision = parseInt(input.attr("data-numeric-precision"))
			val = input.val().trim().replace(",", ".")

			# Set precision
			precision = $.cowtech.numeric.precision if isNaN(precision) || precision < 1

			# Check if valid
			val = "0" if val.length == 0 || !regex["float"].test(val)

			# Round to n decimal digit
			val = $.cowtech.utils.parse_float(val)
			input.data("numeric-value", val)

			# Set value
			input.val(val.toFixed((if (is_float) then precision else 0)).replace(".", ","))

			# Set classes
			input.removeClass("numeric-positive numeric-negative numeric-zero numeric-unset")
			if val == 0
				input.addClass("numeric-zero")
				input.addClass("numeric-unset") if not_zero == true
			else
				input.addClass((if (val > 0) then "numeric-positive" else "numeric-negative")) if input.attr("data-numeric-add-classes") == "true"

			!(positive && val < 0) || input.is("[required].numeric-unset") || input.is(".required.numeric-unset")
		)

	$.fn.cowtech_numeric = (->
		@each ->
			el = $(this)
			el.on("change", ->
				$.cowtech.numeric.handle(el)
			).on("focus", ->
				val = el.val().trim().replace(",", ".")
				el.val("") if parseFloat(val) == 0
				el.css(
					color: "black"
					fontStyle: "normal"
				).removeClass("positive negative zero unset")
			).on("blur", ->
				$(el).css(
					color: null
					fontStyle: null
				)

				$.cowtech.numeric.handle(el)
			).addClass("numeric").change()
	)

	$.fn.numberize = (->
		$.cowtech.numeric.handle(this) if @is(".numeric")
	)
)(jQuery)
