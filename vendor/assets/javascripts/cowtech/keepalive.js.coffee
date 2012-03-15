###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.keepalive =
		autostart: true
		last_update: 0
		interval: null
		check_timeout: 300
		expire: 300
		uri: null
		callbacks:
			updated: []
			skipped: []

		timestamp: (->
			Math.round((new Date()).getTime() / 1000)
		)

		update: (->
			$.cowtech.keepalive.last = $.cowtech.keepalive.timestamp()
			$.getJSON($.cowtech.keepalive.uri) if !$.cowtech.utils.is_blank($.cowtech.keepalive.uri)
		)

		check: (->
			now = $.cowtech.keepalive.timestamp()
			if now - $.cowtech.keepalive.last >= $.cowtech.keepalive.expire
				$.cowtech.keepalive.update()

				$.each($.cowtech.keepalive.callbacks.updated, (index, callback) ->
					callback()
				)
			else
				$.each($.cowtech.keepalive.callbacks.skipped, (index, callback) ->
					callback()
				)
		)

		start: (->
			$.cowtech.keepalive.uri = $.cowtech.data.params.keepalive_url
			$.cowtech.keepalive.last = $.cowtech.keepalive.timestamp()
			$.cowtech.keepalive.interval = setInterval($.cowtech.keepalive.check, $.cowtech.keepalive.check_timeout * 1000)
		)

		stop: (->
			clearInterval($.cowtech.keepalive.interval) if !$.cowtech.utils.is_blank($.cowtech.keepalive.interval)
		)

		autoload: (->
			$.cowtech.keepalive.start() if $.cowtech.keepalive.autostart == true
		)
)(jQuery)
