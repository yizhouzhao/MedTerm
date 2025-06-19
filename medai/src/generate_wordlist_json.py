import os
from openai import OpenAI
from dotenv import load_dotenv
import json
import re
import click

# Load environment variables from .env file
load_dotenv()

# Initialize OpenAI client with API key
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Verify API key is set
if not os.getenv('OPENAI_API_KEY'):
    raise ValueError("OPENAI_API_KEY environment variable is not set")

def extract_json_from_markdown(content):
    """
    Extract JSON from markdown code blocks.
    Handles cases where the response is wrapped in ```json ... ``` blocks.
    """
    # Try to find JSON within markdown code blocks
    json_pattern = r'```(?:json)?\s*(\{.*?\})\s*```'
    match = re.search(json_pattern, content, re.DOTALL)
    
    if match:
        return match.group(1)
    
    # If no markdown blocks found, try to parse the entire content as JSON
    return content.strip()

def parse_json_response(response_content):
    """
    Safely parse JSON response with error handling.
    """
    try:
        # Extract JSON from markdown if present
        json_str = extract_json_from_markdown(response_content)
        
        # Parse the JSON
        parsed_json = json.loads(json_str)
        return parsed_json
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        print(f"Raw content: {response_content}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None


def generate_word_json(word):
    # chat with openai to generate a wordlist json
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are teaching medical terms. For each medical word, please tell me its meaning, Chinese Translation, Traditional Chinese Translation, explanation, and word prefix, root, and suffix. Please make sure that the word is a medical term. And if you think the word doesn't have a prefix, root, or suffix, please leave it blank."},
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
            {"type":"object","properties":{"output":{"type":"object","properties":{"word":{"type":"string"},"prefix":{"type":"string"},"root":{"type":"string"},"suffix":{"type":"string"},"meaning":{"type":"string"},"explanation":{"type":"string"},"chineseTranslation":{"type":"string"},"traditionalChineseTranslation":{"type":"string"}},"additionalProperties":false}},"additionalProperties":false,"$schema":"http://json-schema.org/draft-07/schema#"}
            ```
            """},
            {"role": "user", "content": word}
        ]
    )
    
    response_content = response.choices[0].message.content
    print("Raw API Response:")
    print(response_content)
    print("\n" + "="*50 + "\n")
    
    # Parse the response to json with error handling
    json_response = parse_json_response(response_content)
    
    if json_response and "output" in json_response:
        print("Parsed JSON Output:")
        print(json_response["output"])
    else:
        print("Failed to parse JSON response or 'output' key not found")

    return json_response["output"]


@click.command()
@click.option('--input_file', type=str, help='The input file to generate a wordlist for')
@click.option('--output_file', type=str, help='The output file to save the wordlist to')
@click.option('--input_format', type=str, help='The input format of the wordlist')
@click.option('--lesson', type=int, help='The lesson number to generate a wordlist for')
def main(input_file, output_file, input_format, lesson):
    import os
    print("[generate_wordlist_json] Current working directory:", os.getcwd())
    input_file = os.path.join(os.getcwd(), input_file)
    print("[generate_wordlist_json] Input file:", input_file)
    if input_format == "json":
        with open(input_file, 'r') as f:
            words = json.load(f)
    elif input_format == "txt":
        with open(input_file, 'r') as f:
            words = f.readlines()
    else:
        raise ValueError("Invalid input format")

    med_words = []
    for word in words[:3]: # TODO: remove this
        med_word = generate_word_json(word)
        med_word["lesson"] = lesson
        med_words.append(med_word)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "version": "0.0.1",
            "words": med_words
        }, f, indent=4, ensure_ascii=False)

if __name__ == "__main__":
    # run the script with the following arguments:
    # python src/generate_wordlist_json.py --input_file ../data/lessons/1.json --output_file ../data/1.json --input_format json --lesson 1
    main()