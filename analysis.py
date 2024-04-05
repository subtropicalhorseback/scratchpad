import os
import logging
import google.generativeai as genai

# Setup logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    handlers=[logging.FileHandler("/home/opslab/Documents/geminiprompts/geopolitical_analysis.log"), logging.StreamHandler()])

def configure_api():
    """
    Configures the API with the user's API key.
    """
    api_key = os.getenv('GOOGLE_API_KEY')
    if not api_key:
        logging.error("GOOGLE_API_KEY environment variable is not set.")
        raise ValueError("Please set the 'GOOGLE_API_KEY' environment variable.")
    genai.configure(api_key=api_key)

def get_prompt_from_file(mode):
    """
    Reads the prompt from a file corresponding to the chosen mode.
    """
    prompt_path = f"/home/opslab/Documents/geminiprompts/mode{mode}prompt.txt"
    try:
        with open(prompt_path, 'r', encoding='utf-8') as file:
            return file.read()
    except FileNotFoundError:
        logging.error(f"Prompt file for mode {mode} not found.")
        return None

def start_mode_analysis(mode, initial_prompt):
    """
    Initializes a chat session for a given mode of analysis with an initial prompt.
    """
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
    
    # Assuming 'model' is globally accessible for token counting; if not, it needs to be passed as an argument.
    token_count = chat.model.count_tokens(chat.history)
    logging.info(f"Total tokens used in chat session: {token_count}")

def main():
    """
    Main execution function. Orchestrates the flow of operations.
    """
    configure_api()

    mode = input("Enter analysis mode (1, 2, or 3): ")
    prompt = get_prompt_from_file(mode)
    if prompt:
        chat_session = start_mode_analysis(mode, prompt)
        
        while True:
            further_instructions = input("Enter further instructions or 'exit' to end: ")
            if further_instructions.lower() == 'exit':
                break
            refine_analysis(chat_session, further_instructions)
    else:
        print("Failed to load the prompt. Exiting.")

if __name__ == "__main__":
    main()
