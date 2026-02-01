import { createResponse } from "./index";

describe("createResponse", () => {
  it("200 と body を返す", () => {
    const res = createResponse("test message");
    const bodyObj = JSON.parse(res.body)
    expect(res.statusCode).toEqual(200)
    expect(bodyObj.message).toEqual('test message')
    expect(bodyObj.id).toBeDefined()
  });
});