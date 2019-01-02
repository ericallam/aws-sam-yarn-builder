const { ping } = require("local-file-dependency");

let response;

export const lambdaHandler = async (event: any = {}): Promise<any> => {
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
