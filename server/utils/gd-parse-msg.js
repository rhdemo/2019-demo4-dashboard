const gdComUtils = require('@gd-com/utils');

module.exports = function gdParseMsg(gdMsg) {
  let gdBuffer = new gdComUtils.GdBuffer(gdMsg);
  return JSON.parse(gdBuffer.getString());
};