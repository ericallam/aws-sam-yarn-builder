const _ = require("lodash");

const ping = message => _.identity(message);

module.exports = {
  ping
};
