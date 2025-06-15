import os
from openai import OpenAI
from dotenv import load_dotenv
import json
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import click

# Load environment variables from .env file
load_dotenv()

# Initialize OpenAI client with API key
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Verify API key is set
if not os.getenv('OPENAI_API_KEY'):
    raise ValueError("OPENAI_API_KEY environment variable is not set")


def generate_medword(word: str):
    print("processing word: ", word)
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
            {"type":"object","properties":{"output":{"type":"array","items":{"type":"object","properties":{"word":{"type":"string"},"prefix":{"type":"string"},"root":{"type":"string"},"suffix":{"type":"string"},"meaning":{"type":"string"},"explanation":{"type":"string"},"chineseTranslation":{"type":"string"},"category":{"type":"string"}},"required":["word","prefix","root","suffix","meaning","explanation","chineseTranslation","category"],"additionalProperties":false}}},"additionalProperties":false,"$schema":"http://json-schema.org/draft-07/schema#"}
            ```
            """},
            {"role": "user", "content": word}
        ]
    )
    
    try:
        # Get the content and remove markdown code block if present
        content = response.choices[0].message.content
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0].strip()
        
        # Parse the response to json
        json_response = json.loads(content)
        print("json_response: ", json_response)
        return json_response["output"][0]
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON for word '{word}': {e}")
        print("Raw response content:")
        print(response.choices[0].message.content)
        return None

@click.command()
@click.option('--inputfile', type=click.Path(exists=True), default='../data/lessions/1.json')
@click.option('--outputfile', type=click.Path(exists=True), default='../data/wordlist.json')
@click.option('--classname', type=str, default='general')
def main(inputfile, outputfile, classname):
    # read the data/sample.json file
    wordlist = {
        "version": "0.0.1",
        "words": []
    }
    
    with open(inputfile, 'r') as f:
        words = json.load(f)
    
    # Process words in parallel
    with ThreadPoolExecutor(max_workers=8) as executor:
        # Submit all tasks and get futures
        future_to_word = {executor.submit(generate_medword, word): word for word in words}
        
        # Process completed tasks with progress bar
        for future in tqdm(as_completed(future_to_word), total=len(words), desc="Processing words"):
            word = future_to_word[future]
            try:
                result = future.result()
                if result:
                    if classname:
                        result["category"] = classname
                    wordlist["words"].append(result)
            except Exception as e:
                print(f"Error processing word '{word}': {e}")
    
    # Write the wordlist to the data/wordlist.json file
    with open(outputfile, 'w', encoding='utf-8') as f:
        json.dump(wordlist, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()