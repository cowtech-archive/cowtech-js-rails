###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.messages =
		root: null
		config:
			msg:
				element: "div"
				classes: ""
			title:
				element: "h4"
				classes: ""
			closer:
				element: "a"
				classes: "close"
				html: "×"
		timeouts:
			success: 3000
			info: 5000
		loader:
			message: "Loading ..."
			image: "/images/loading.gif"
		labels:
			close: "Close"
			http_error: "HTTP Error"
			no_reply: "No reply from server."
			check_connection: "Check network connection."

		autoload: (->
			$.cowtech.messages.root = $("[data-messages-role=root]")
		)

		clear: (->
			$.cowtech.messages.root.html("")
		)

		create_msg: ((type, options) ->
			options = $.cowtech.utils.initialize(options, {})
			rv = $("<#{$.cowtech.messages.config.msg.element}/>").addClass($.cowtech.messages.config.msg.classes).addClass("alert-" + type)
			rv.attr("data-messages-role", "message").prependTo($.cowtech.messages.root).hide()
			rv.attr("data-messages-id", options["id"]) if !$.cowtech.utils.is_null(options["id"])
			rv
		)

		create_title: ((type, msg, options) ->
			msg = $.cowtech.utils.initialize(msg, $.cowtech.messages.loader.message)
			icon = ""

			if type == "loading"
				icon = "<img class=\"message-icon\" alt=\"#{msg}\" src=\"#{$.cowtech.messages.loader.image}\"/><span class=\"c-icon-label\">#{msg}</span>"
			else
				icon = "<span class=\"message-icon #{type}\"></span>#{msg}"
			rv = $("<#{$.cowtech.messages.config.title.element}/>").addClass($.cowtech.messages.config.title.classes)
			rv.attr("data-messages-role", "title").html(icon)
			rv
		)

		create_closer: ((options) ->
			rv = $("<#{$.cowtech.messages.config.closer.element}/>").addClass($.cowtech.messages.config.closer.classes)
			rv.attr("href", "#") if $.cowtech.messages.config.closer.element == "a"
			rv.attr("data-messages-role", "close").html($.cowtech.messages.config.closer.html)
			rv
		)

		loading: ((msg, options) ->
			options = $.extend($.cowtech.utils.initialize(options, {}), {
				id: "loading"
				no_animations: true
			})

			msg = $.cowtech.utils.initialize(msg, "")
			$.cowtech.messages.show("loading", msg, options)
		)

		show: ((type, msg, options) ->
			options = $.cowtech.utils.initialize(options, {})
			msg = $.cowtech.utils.initialize(msg, "")

			$.cowtech.messages.clear() if options["clear"] == true

			container = $.cowtech.messages.create_msg(type, options)
			title = null

			if $.cowtech.utils.is_object(msg)
				title = $.cowtech.messages.create_title(type, msg.title, options).appendTo(container)
				$("<p data-messages-role=\"details\"></p>").appendTo(container).html(msg.message || msg.msg)
			else
				title = $.cowtech.messages.create_title(type, msg, options).appendTo(container)

			if type != "loading"
				closer = $.cowtech.messages.create_closer(options).prependTo(title).on("click", (ev) ->
					ev.preventDefault()

					if options.no_animations == true
						container.remove()
					else
						container.slideUp("fast", ->
							$(this).remove()
						)
				)

			$("<p data-message-role=\"error\"></p>").appendTo(container).html("#{options.http.message} (#{$.cowtech.messages.labels.http_error} #{options.http.status})") if type == "error" && !$.cowtech.utils.is_null(options.http)
			timeout = $.cowtech.messages.timeouts[type]

			if options.no_autohide != true && !$.cowtech.utils.is_blank(timeout)
				setTimeout((->
					container.find("[data-messages-role=close]").click()
				), timeout)
			if options.no_animations == true
				container.show()
			else
				container.slideDown("fast")

			options.showed() if !$.cowtech.utils.is_null(options.showed)
		)

		has_message: ((id) ->
			$.cowtech.messages.root.find("[data-messages-id=\"#{id}\"]").size() > 0
		)

		alert: ((type, msg) ->
			if $.cowtech.utils.module_active("modal")
				root = $("<div></div>")
				container = $("<div data-messages-role=\"alert\"></div>").appendTo(root)
				h2 = $("<h2><span class=\"message-icon #{type}\"></span><span></span></h2>").appendTo(container)

				if $.cowtech.utils.is_object(msg)
					h2.find("span:not(.message-icon)").html(msg.title)
					$("<p data-message-role=\"details\"></p>").appendTo(container).html(msg.message || msg.msg)
				else
					h2.find("span:not(.message-icon)").html(msg)

				buttons = $("<div class=\"buttons\"></div>").appendTo(container)
				$("<button class=\"button btn btn-primary\" data-messages-role=\"alert-close\">#{$.cowtech.messages.labels.close}</button>").appendTo(buttons)

				$.cowtech.modal.callbacks.completed.push(->
					$("[data-messages-role=\"alert-close\"]").on("click", (ev) ->
						$.cowtech.modal.close()
						false
					)
				)

				$.cowtech.modal.open("#", {
					autoScale: false
					autoDimensions: false
					content: root.html()
					iframe: false
					width: 700
					height: 700
					scrolling: false
				})
			else
				alert(msg)
		)

		pause: ((amount) ->
			start = new Date()
			current = null
			loop
				current = new Date()
				break if current - start >= amount
		)

		confirm: ((type, msg) ->
			confirm(msg)
		)

	$.cowtech.ajax =
		pending_requests: []

		set_custom_events: ((value) ->
			if value == true
				$.cowtech.messages.root.addClass("custom-ajax-events")
			else
				$.cowtech.messages.root.removeClass("custom-ajax-events")
		)

		custom_events: (->
			$.cowtech.messages.root.is(".custom-ajax-events")
		)

		start: ((force) ->
			return if force != true && $.cowtech.ajax.custom_events()
			$.cowtech.ajax.pending_requests.push(force) if $.cowtech.utils.is_object(force)
			$.cowtech.messages.loading($.cowtech.messages.loader.message) if !$.cowtech.messages.has_message("loading")
		)

		end: ((force) ->
			return if force != true && $.cowtech.ajax.custom_events()
			$.cowtech.ajax.pending_requests.pop() if $.cowtech.utils.is_object(force)

			if $.cowtech.ajax.pending_requests.length == 0
				$.cowtech.messages.root.find("[data-messages-id=loading]").slideUp("fast", ->
					$(this).remove()
				)
		)

		autoload: (->
			$.ajaxSetup(
				cache: false
				timeout: 60000
			)

			$(document).ajaxSend($.cowtech.ajax.start)
			$(document).ajaxComplete($.cowtech.ajax.end)
			$(document).ajaxError((e, xhr, settings, error) ->
				return if $.cowtech.ajax.custom_events() || xhr.status != 0

				$.cowtech.messages.show("error", $.cowtech.messages.labels.no_reply, {
					http:
						status: 400
						message: $.cowtech.messages.labels.check_connection
					}
				)
				e.stopPropagation()
			)

			$(window).on("unload", ->
				# TODO: Avoid error on page change
				$.each($.cowtech.ajax.pending_requests, (index, request) ->
					request.abort()
				)

				$.cowtech.ajax.pending_requests = []
				$.cowtech.ajax.end()
			)

			$("tr").attr("data-ajax-role", "container")

			$("body").on("ajax:success", "a[data-remote=true]", (ev, data, status, xhr) ->
				el = $(this)
				if el.attr("data-type") == "html"
					old_row = el.closest("[data-ajax-role=container]")

					if $.cowtech.utils.is_blank(data)
						old_row.slideUp("fast", ->
							old_row.remove()
						)
					else
						new_row = $(data).attr("data-ajax-role", "container").hide()

						old_row.fadeOut("fast", ->
							old_row.replaceWith(new_row)
							new_row.fadeIn("fast")
						)

						$.cowtech.modal.setup new_row.find("[data-modal=true]")
				else
					$.cowtech.messages.show((if data.success then "success" else "error"), data.reply)
			)
		)
)(jQuery)
