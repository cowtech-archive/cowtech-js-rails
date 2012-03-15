###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

if !String::trim?
	String::trim = (->
		@replace /(^\s+)|(\s+$)/g, ""
	)

Date.labels =
	months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	monthsShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	days: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	daysShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	daysMin: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
Date.localized_labels = Date.labels

String::toDateTime = (->
	rv = new Date()
	mo = @match(/([a-z]{3}) ([a-z]{3}) (\d{2}) (\d{2}):(\d{2}):(\d{2}) (\+[0-9]{4}) ([0-9]{4})$/i)
	rv.setUTCFullYear(parseInt(mo[8]), Date.labels.shortMonths.indexOf(mo[2]), parseInt(mo[3]))
	rv.setUTCHours(parseInt(mo[4]), parseInt(mo[5]), parseInt(mo[6]))
	rv
)

Date::toShortString = (->
	days = @getDate()
	hours = @getHours()
	minutes = @getMinutes()
	day = "0#{days}"  if days < 10
	hours = "0#{hours}"  if hours < 10
	minutes = "0#{minutes}"  if minutes < 10
	"{day} {Date.localized_labels.months[@getMonth()]} {@getFullYear()}, {hours}:{minutes}"
)

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.data = {}

	$.cowtech.utils =
		initialize: ((obj, def) ->
			if $.cowtech.utils.is_blank(obj) then def else obj
		)

		module_active: ((module) ->
			eval("!$.cowtech.utils.is_null($.fn.cowtech_" + module + ") || !$.cowtech.utils.is_null($.cowtech." + module + ");")
		)

		is_null: ((obj) ->
			!obj? || $.cowtech.utils.is_of_type(obj, "undefined")
		)

		is_blank: ((obj) ->
			$.cowtech.utils.is_null(obj) || obj.toString().match(/^\s*$/)?
		)

		is_of_type: ((obj, type) ->
			typeof(obj) == type
		)

		is_object: ((obj) ->
			$.cowtech.utils.is_of_type(obj, "object")
		)

		length: ((obj) ->
			rv = 0
			(rv++) for i of obj
			rv
		)

		format_currency: ((number, currency, precision) ->
			precision = $.cowtech.utils.initialize(precision, $.cowtech.numeric.precision)
			rv = number.toFixed(precision).toString().replace(".", ",")
			rv += " #{currency}" if !$.cowtech.utils.is_blank(currency)
			rv
		)

		parse_float: ((number, precision) ->
			rv = $.cowtech.utils.round_number(parseFloat(number.replace(",", ".")), precision)
			if isNaN(rv) then 0 else rv
		)

		round_number: ((number, precision) ->
			prec = Math.pow(10, $.cowtech.utils.initialize(precision, $.cowtech.numeric.precision))
			Math.round(parseFloat(number) * prec) / prec
		)

		detect_browser: ((not_add) ->
			rv = null

			$.ajax(
				async: false
				url: "http://#{document.domain.replace(/^forum\./, "")}/detect-browser"
				dataType: "jsonp"
				success: (data, textStatus, xhr) ->
					if data.success
						rv = data.data
						$("body").addClass rv.classes if !not_add == true
			)

			rv
		)

		is_mobile: (->
			!$.cowtech.utils.is_null($.mobile)
		)
)(jQuery)
