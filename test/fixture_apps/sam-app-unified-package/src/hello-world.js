const { ping } = require("local-file-dependency");

exports.handler = async (event, context) => {
  try {
    response = {
      statusCode: 200,
      body: JSON.stringify({
        message: ping("hello world")
      })
    };
  } catch (err) {
    console.log(err);
    return err;
  }

  return response;
};
