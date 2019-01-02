const { ping } = require("local-file-dependency");

exports.lambdaHandler = async (event, context) => {
  event.Records.forEach(record => {
    console.log(
      JSON.stringify({
        message: ping(record.Sns.Message)
      })
    );
  });
};
