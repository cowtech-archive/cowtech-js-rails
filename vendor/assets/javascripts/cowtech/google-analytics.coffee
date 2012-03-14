###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

_gaq = []

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.google_analytics =
		setup: ((account, domain) ->
			_gaq = [["_setAccount", account], ["_setDomainName", domain], ["_trackPageview" ]]
			ga = document.createElement("script")
			ga.type = "text/javascript"
			ga.async = true
			ga.src = (if "https:" is document.location.protocol then "https://ssl" else "http://www") + ".google-analytics.com/ga.js"
			s = document.getElementsByTagName("script")[0]
			s.parentNode.insertBefore(ga, s)
		)
)(jQuery)
