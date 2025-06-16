import os
from openai import OpenAI
from dotenv import load_dotenv
import json
# Load environment variables from .env file
load_dotenv()

# Initialize OpenAI client with API key
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Verify API key is set
if not os.getenv('OPENAI_API_KEY'):
    raise ValueError("OPENAI_API_KEY environment variable is not set")


if __name__ == "__main__":
    # chat with openai to generate a wordlist json
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are teaching medical terms. For each medical word, please tell me its meaning, Chinese Translation, explanation, and word prefix, root, and suffix. "},
            {"role": "assistant", "content": 
            """ 
            You must format your output as a JSON value that adheres to a given "JSON Schema" instance.

            "JSON Schema" is a declarative language that allows you to annotate and validate JSON documents.

            For example, the example "JSON Schema" instance {{"properties": {{"foo": {{"description": "a list of test words", "type": "array", "items": {{"type": "string"}}}}}}, "required": ["foo"]}}}}
            would match an object with one required property, "foo". The "type" property specifies "foo" must be an "array", and the "description" property semantically describes it as "a list of test words". The items within "foo" must be strings.
            Thus, the object {{"foo": ["bar", "baz"]}} is a well-formatted instance of this example "JSON Schema". The object {{"properties": {{"foo": ["bar", "baz"]}}}} is not well-formatted.

            Your output will be parsed and type-checked according to the provided schema instance, so make sure all fields in your output match the schema exactly and there are no trailing commas!

            Here is the JSON Schema instance your output must adhere to. Include the enclosing markdown codeblock:
            ```json
            {"type":"object","properties":{"output":{"type":"object","properties":{"word":{"type":"string"},"prefix":{"type":"string"},"root":{"type":"string"},"suffix":{"type":"string"},"meaning":{"type":"string"},"explanation":{"type":"string"},"chineseTranslation":{"type":"string"},"category":{"type":"string"}},"additionalProperties":false}},"additionalProperties":false,"$schema":"http://json-schema.org/draft-07/schema#"}
            ```
            """},
            {"role": "user", "content": "Carcinoma"}
        ]
    )
    print(response.choices[0].message.content)
    # parse the response to json
    json_response = json.loads(response.choices[0].message.content)
    print(json_response["output"])