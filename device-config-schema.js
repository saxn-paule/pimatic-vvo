module.exports = {
  title: "pimatic-vvo device config schemas",
  VvoDevice: {
    title: "VvoDevice config options",
    type: "object",
    extensions: ["xAttributeOptions"],
    properties: {
      attributes: {
        description: "Attributes of the device",
        type: "array"
      }
    }
  }
};