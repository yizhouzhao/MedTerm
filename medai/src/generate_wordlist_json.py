import os
from openai import OpenAI
from dotenv import load_dotenv
import json
import re
import click
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

# Load environment variables from .env file
load_dotenv()

# Initialize OpenAI client with API key
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Verify API key is set
if not os.getenv('OPENAI_API_KEY'):
    raise ValueError("OPENAI_API_KEY environment variable is not set")

# Thread-local storage for rate limiting
thread_local = threading.local()

def get_client():
    """Get thread-local OpenAI client"""
    if not hasattr(thread_local, 'client'):
        thread_local.client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    return thread_local.client

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
    """Generate JSON data for a single word using thread-local client"""
    try:
        # Get thread-local client
        thread_client = get_client()
        
        # chat with openai to generate a wordlist json
        response = thread_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are teaching medical terms. For each medical word, please tell me its meaning, Chinese Translation, Traditional Chinese Translation, explanation, and word prefix, root, and suffix. Please make sure that you give the translation for its medical meaning. And if you think the term doesn't have a prefix, root, or suffix, or the term is composed by two or more words, please leave it blank. Besides, you may need to change spelling and capitalization if necessary."},
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
            return json_response["output"]
        else:
            print("Failed to parse JSON response or 'output' key not found")
            return None
            
    except Exception as e:
        print(f"Error processing word '{word}': {e}")
        return None

def process_word_with_retry(word, max_retries=3):
    """Process a word with retry logic for better reliability"""
    for attempt in range(max_retries):
        try:
            result = generate_word_json(word)
            if result:
                return result
            else:
                print(f"Attempt {attempt + 1} failed for word: {word}")
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)  # Exponential backoff
        except Exception as e:
            print(f"Attempt {attempt + 1} failed for word '{word}': {e}")
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
    
    print(f"All attempts failed for word: {word}")
    return None

@click.command()
@click.option('--input_file', type=str, help='The input file to generate a wordlist for')
@click.option('--output_file', type=str, help='The output file to save the wordlist to')
@click.option('--lesson', type=int, help='The lesson number to generate a wordlist for')
@click.option('--version', type=str, help='The version of the wordlist', default='0.0.1')
@click.option('--debug', is_flag=True, help='Enable debug mode', default=False)
def main(input_file, output_file, lesson, version, debug):
    print("[generate_wordlist_json] Current working directory:", os.getcwd())
    input_file = os.path.join(os.getcwd(), input_file)
    print("[generate_wordlist_json] Input file:", input_file)
    input_format = input_file.split('.')[-1]
    if input_format == "json":
        with open(input_file, 'r') as f:
            words = json.load(f)
    elif input_format == "txt":
        with open(input_file, 'r') as f:
            words = f.readlines()
    else:
        raise ValueError("Invalid input format")

    print(f"Found {len(words)} words to process")
    
    # remove duplicate words
    words = list(set(words))

    # Debug mode: only process the first 5 words
    if debug: 
        words = words[:5]

    # Process words in parallel
    max_workers = 5  # Adjust based on your API rate limits
    med_words = []
    failed_words = []
    
    print(f"Processing {len(words)} words with {max_workers} parallel workers...")
    
    # Create a list to store results in order
    results = [None] * len(words)
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Submit all tasks with their indices
        future_to_index = {executor.submit(process_word_with_retry, word.strip().lower()): i for i, word in enumerate(words)}
        
        # Process completed tasks
        for future in as_completed(future_to_index):
            index = future_to_index[future]
            word = words[index]
            try:
                med_word = future.result()
                if med_word:
                    med_word["lesson"] = lesson
                    results[index] = med_word
                    print(f"✓ Processed ({index+1}/{len(words)}): {word}")
                else:
                    failed_words.append(word)
                    print(f"✗ Failed ({index+1}/{len(words)}): {word}")
            except Exception as e:
                failed_words.append(word)
                print(f"✗ Exception ({index+1}/{len(words)}): {word} - {e}")
    
    # Filter out None results and create final med_words list
    med_words = [result for result in results if result is not None]
    
    print(f"\nProcessing complete!")
    print(f"Successfully processed: {len(med_words)} words")
    print(f"Failed: {len(failed_words)} words")
    
    if failed_words:
        print(f"Failed words: {failed_words}")

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "version": version,
            "words": med_words
        }, f, indent=4, ensure_ascii=False)

if __name__ == "__main__":
    # run the script with the following arguments:
    # python src/generate_wordlist_json.py --input_file ../data/lessons/1.json --output_file ../data/1.json --lesson 1 --version 0.0.1 --debug
    # python src/generate_wordlist_json.py --input_file ../data/lessons/2.txt --output_file ../data/2.json --lesson 2 --version 0.0.1 --debug
    # python src/generate_wordlist_json.py --input_file ../data/lessons/3.txt --output_file ../data/3.json --lesson 3 --version 0.0.1 --debug
    main()