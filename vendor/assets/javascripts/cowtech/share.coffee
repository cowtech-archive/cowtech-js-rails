###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.share =
		autoload: ((config) ->
			$("div.share").cowtech_share(config)
			hide_tips = ->
				$(".qtip").qtip("hide")

			$(window).on("scroll", hide_tips)

			$("div, section").each(->
				$(this).on("scroll", hide_tips) if $(this).css("overflow-y") == "scroll"
			)
		)

	$.fn.cowtech_share = ((config) ->
		@each(->
			body = $(this).hide()
			config = $.cowtech.utils.initialize(config, {
				yadjust: yadjust_def
			})

			yadjust_def = -2
			yadjust = $.cowtech.utils.initialize(config.yadjust, yadjust_def)

			body.parent().find("h2").qtip(
				content:
					text: body
				position:
					my: "top left"
					at: "bottom left"
					viewport: $(window)
					adjust:
						x: 10
						y: yadjust
				style:
					classes: "ui-tooltip-share ui-tooltip-shadow"
					tip:
						corner: "top left"
						mimic: "center"
						border: 1
						width: 22
						height: 11
						offset: 10
				show:
					delay: 500
				hide:
					event: "unfocus"
			)
		)
	)
)(jQuery)
