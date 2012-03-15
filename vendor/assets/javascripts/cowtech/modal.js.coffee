###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.modal =
		active: "colorbox"
		root: null
		callbacks:
			loading: []
			completed: []
			closed: []

		autoload: (->
			$("[data-modal=true]").each(->
				$.cowtech.modal.setup $(this)
			)
		)

		close: (->
			if $.cowtech.modal.active == "fancybox"
				$.fancybox.close()
			else if $.cowtech.modal.active == "colorbox"
				$.colorbox.close()
		)

		parent_close: (->
			if $.cowtech.modal.active == "fancybox"
				window.top.window.$.fancybox.close()
			else if $.cowtech.modal.active == "colorbox"
				window.top.window.$.colorbox.close()
		)

		toggle_reload_parent: (->
			$(window).data("modal-reload", "yes")
		)

		on_loading: (->
			$.each($.cowtech.modal.callbacks.loading, (index, callback) ->
				callback()
			)
		)

		on_complete: (->
			$.cowtech.modal.root = $("#cboxContent") if $.cowtech.modal.active == "colorbox"

			$.each($.cowtech.modal.callbacks.completed, (index, callback) ->
				callback()
			)
		)

		on_closed: (->
			$.each($.cowtech.modal.callbacks.closed, (index, callback) ->
				callback()
			)

			if $(window).data("modal-reload") == "yes"
				$(window).data("modal-reload", "no")
				window.location.reload()
		)

		finalize_config: ((rv) ->
			if $.cowtech.modal.active == "fancybox"
				rv["type"] = null if !$.cowtech.utils.is_blank(rv["content"])
			else if $.cowtech.modal.active == "colorbox"
				if !$.cowtech.utils.is_blank(rv["content"])
					rv["html"] = rv["content"]
					rv["content"] = null
					rv["width"] = null
					rv["height"] = null
					rv["type"] = null

			rv
		)

		get_config: ((override, raw) ->
			raw_defaults =
				colorbox:
					onLoad: ->
						$("#cboxClose").hide()
						$.cowtech.modal.on_loading()
					onComplete: ->
						$("#cboxClose").show().addClass("c-icon c-icon-24 close")
						$.cowtech.modal.on_complete()
					onClosed: $.cowtech.modal.on_closed

			defaults =
				fancybox:
					autoScale: false
					autoDimensions: false
					width: 1400
					height: 850
					scrolling: "no"
					titleShow: false
					type: "iframe"
					overlayOpacity: 0.8
					overlayColor: "#404040"
					speedIn: 0
					speedOut: 0
					transitionIn: "none"
					transitionOut: "none"
					easingIn: "none"
					easingOut: "none"
					onClosed: $.cowtech.on_closed
				colorbox:
					autoScale: false
					autoDimensions: false
					width: 1080
					height: 950
					transition: "none"
					iframe: true
					fixed: true
					fastIframe: true
					title: false
					speed: 0
					scrolling: false
					onLoad: ->
						$("#cboxClose").hide()
						$.cowtech.modal.on_loading()
					onComplete: ->
						$("#cboxClose").show().addClass("c-icon c-icon-24 close")
						$.cowtech.modal.on_complete()
					onClosed: $.cowtech.modal.on_closed

			dict = (if raw is true then raw_defaults else defaults)
			$.cowtech.modal.finalize_config($.extend(dict[$.cowtech.modal.active], override))
		)

		add: ((el, config) ->
			if $.cowtech.modal.active == "fancybox"
				if el.is(".file")
					config.type = "image"
					delete config["width"]
					delete config["height"]
				el.fancybox(config)
			else if $.cowtech.modal.active == "colorbox"
				is_file = el.is("file")
				delete config["width"]  if is_file || config["width"] == "auto"
				delete config["height"]  if is_file || config["height"] == "auto"
				el.colorbox(config)
		)

		open: ((url, config) ->
			url = $.cowtech.utils.initialize(url, "#")
			config = $.cowtech.utils.initialize(config, {})
			link = $("<a href=\"#{url}\" data-modal=\"true\"></a>").appendTo($("body"))
			$.cowtech.modal.setup(link, config)
			link.click().remove()
		)

		setup: ((el, config) ->
			override = {}
			eld = el.get(0)
			use_raw = false
			return if el.size() == 0
			config = $.cowtech.utils.initialize(config, {})

			$.each(eld.attributes, (index) ->
				name = eld.attributes[index].name
				if name.match(/^data-modal-(.+)/)
					if name != "data-modal-defaults"
						override[name.replace("data-modal-", "")] = eld.attributes[index].value
					else
						override = {}
						use_raw = true
						false
			)

			$.cowtech.modal.add(el, $.cowtech.modal.get_config($.extend(override, config), use_raw))
		)
)(jQuery)
