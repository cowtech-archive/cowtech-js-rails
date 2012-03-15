###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.clipboard =
		swf: "",

		setup: ((el, options) ->
			return if el.size() == 0

			clipboard = new ZeroClipboard.Client()
			text = el.attr("data-clipboard-data")
			msg = el.attr("data-clipboard-msg")
			options = $.cowtech.utils.initialize(options, {})

			text = el.attr("href") if $.cowtech.utils.is_null(text)
			msg = "Testo copiato negli appunti." if $.cowtech.utils.is_null(msg)

			copier = clipboard.getHTML(el.outerWidth(), el.outerHeight())
			el.after(copier)
			el.parent().attr("data-clipboard-role", "wrapper")

			if !$.cowtech.utils.is_null(options.set_text)
				clipboard.addEventListener("onMouseDown", options.set_text)
			else
				clipboard.setText(text)

			clipboard.glue(el.get(0))

			clipboard.addEventListener("onComplete", (if !$.cowtech.utils.is_null(options.copied) then options.copied else ((client, text) ->
				$.cowtech.messages.alert("success", msg)
			)))
		)

		autoload: (->
			ZeroClipboard.setMoviePath($.cowtech.clipboard.swf)
			$("[data-clipboard=true]").each(->
				$.cowtech.clipboard.setup($(this))
			)
		)
)(jQuery)
