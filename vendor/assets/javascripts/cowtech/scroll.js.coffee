###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}

	$.cowtech.scroll =
		trigger: null

		autoload: (->
			$.cowtech.scroll.trigger = $("[data-scroll-role=trigger]")

			$.cowtech.scroll.trigger.hide().on("click", (ev) ->
				$("body").animate({
					scrollTop: 0
					},
					"fast"
				)

				false
			)

			$(window).on("scroll", ->
				if $(window).scrollTop() > 0
					$.cowtech.scroll.trigger.fadeIn()
				else
					$.cowtech.scroll.trigger.fadeOut()
			)
		)
)(jQuery)
