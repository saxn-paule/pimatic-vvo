# iframe configuration options
module.exports = {
	title: "vvo"
	VvoDevice :{
		title: "Plugin Properties"
		type: "object"
		extensions: ["xLink"]
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
}
