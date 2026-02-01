import { APIGatewayProxyHandler } from "aws-lambda";
import { v4 as uuidv4 } from "uuid";

export const handler: APIGatewayProxyHandler = async (event) => {
  const message = "HelloWorld"
  return createResponse(message)
};

export const createResponse = (message: string) => {
  const id = uuidv4();
  return {
    statusCode: 200,
    body: JSON.stringify({
      message,
      id,
    }),
  
  }
}