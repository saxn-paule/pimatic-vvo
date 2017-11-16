# #vvo configuration options
# Declare your config option for your plugin here. 
module.exports = {
	title: "vvo config options"
	type: "object"
	properties:
		stopid:
			description: "The stopId"
			type: "string"
			default: ""
		amount:
			description: "how many vehicles should be shown"
			type: "string"
			default: ""
		offset:
			description: "How far in the future should the first displayed departure be"
			type: "string"
			default: ""
}