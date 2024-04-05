import os
import logging
import google.generativeai as genai

# Setup logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    handlers=[logging.FileHandler("/home/opslab/Documents/geminiprompts/geopolitical_analysis.log"), logging.StreamHandler()])

global country_name  # Global variable to store the country name across different modes

def configure_api():
    """
    Configures the API with the user's API key.
    """
    api_key = os.getenv('GOOGLE_API_KEY')
    if not api_key:
        logging.error("GOOGLE_API_KEY environment variable is not set.")
        raise ValueError("Please set the 'GOOGLE_API_KEY' environment variable.")
    genai.configure(api_key=api_key)

def read_log_for_country(country_name):
    """
    Reads the prompt from a file corresponding to the chosen mode and replaces placeholder with country name.
    """
    log_file_path = "/home/opslab/Documents/geminiprompts/geopolitical_analysis.log"
    log_entries = []
    try:
        with open(log_file_path, 'r', encoding='utf-8') as file:
            for line in file:
                if country_name in line:
                    log_entries.append(line)
    except FileNotFoundError:
        logging.error(f"Log file not found.")
        return None
    return "\n".join(log_entries)

def get_prompt_from_file(mode, country_name):
    """
    Reads the prompt from a file corresponding to the chosen mode and replaces placeholder with country name.
    """
    prompt_path = f"/home/opslab/Documents/geminiprompts/mode{mode}prompt.txt"
    try:
        with open(prompt_path, 'r', encoding='utf-8') as file:
            prompt = file.read().replace("[Target Nation]", country_name)
            logging.info(f"Loaded prompt for mode {mode} targeting {country_name}.")
            return prompt
    except FileNotFoundError:
        logging.error(f"Prompt file for mode {mode} not found.")
        return None

def start_mode_analysis(mode, initial_prompt, country_name):
    """
    Initializes a chat session for a given mode of analysis with an initial prompt.
    Includes log content if mode is 3.
    """
    if mode == "3":
        log_content = read_log_for_country(country_name)
        initial_prompt = f"{log_content}\n\n{initial_prompt}"
    model = genai.GenerativeModel('gemini-pro')
    chat = model.start_chat(history=[])
    response = chat.send_message(initial_prompt)
    logging.info(f"Initial response for mode {mode}:\n{response.text}")
    return chat

def refine_analysis(chat, additional_instructions):
    """
    Refines the analysis by sending additional instructions to the existing chat session.
    """
    response = chat.send_message(additional_instructions, stream=True)
    for chunk in response:
        print(chunk.text)
        logging.info(f"Refinement chunk: {chunk.text}")
    
    token_count = chat.model.count_tokens(chat.history)
    logging.info(f"Total tokens used in chat session: {token_count}")

def interactive_session():
    """
    Runs an interactive analysis session that allows changing modes without exiting.
    """
    global country_name  # Use the global country_name variable
    country_name = input("Enter the target country name: ")
    while True:
        mode = input("Enter analysis mode (1, 2, or 3), 'change country' to switch countries, or 'exit' to quit: ")
        if mode.lower() == 'exit':
            break
        if mode.lower() == 'change country':
            country_name = input("Enter the target country name: ")
            continue

        prompt = get_prompt_from_file(mode, country_name)
        if prompt:
            chat_session = start_mode_analysis(mode, prompt, country_name)
            while True:
                further_instructions = input("Enter further instructions, 'change mode' to switch modes, 'change country' to switch countries, or 'exit' to end: ")
                if further_instructions.lower() == 'exit':
                    break
                elif further_instructions.lower() in ['change mode', 'change country']:
                    logging.info("Changing analysis mode or country.")
                    break
                refine_analysis(chat_session, further_instructions)
        else:
            print("Failed to load the prompt. Exiting.")
            break

def main():
    """
    Main execution function. Configures the API and starts an interactive session.
    """
    configure_api()
    interactive_session()

if __name__ == "__main
