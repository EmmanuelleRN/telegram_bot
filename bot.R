library(telegram.bot)
library(stringr)
try(source('token.R'), silent = TRUE)

# save bot token and updates --------------------------------------------------
bot <- telegram.bot::Bot(token = RLadiesRdg)
updater <- telegram.bot::Updater(token = RLadiesRdg)
updates <- bot$getUpdates()

# first function - start command ----------------------------------------------
start <- function(bot, update){
  bot$send_message(chat_id = update$message$chat_id,
                   text = sprintf("Hello %s!", update$message$from$first_name))
}

start_handler <- CommandHandler("start", start)
updater <- updater + start_handler

# creates command to kill bot -------------------------------------------------
kill <- function(bot, update){ 
  bot$sendMessage(chat_id = update$message$chat_id, 
                  text = "Stopping...") 
  # Clean 'kill' update 
  bot$getUpdates(offset = update$update_id + 1L) 
  # Stop the updater polling 
  updater$stop_polling() 
} 

updater <<- updater + CommandHandler("kill", kill) 

# defines welcome message ------------------------------------------------- 
welcome_text <- "*R-Ladies is a worldwide organization to promote gender diversity in the R community.* We are a part of R-Ladies Global, in Reading. 
 
Our main objective is to *promote the programming R language by sharing knowledge; therefore, anyone interested in learning R is welcome*, independently of knowledge level 🥰 
 
Our target public is the gender minorities, so cis or trans women, trans men, and non-binary people and queer. 
 
We want to make this place a safe haven for learning, so feel free to ask questions and be aware that any form of harassment is not tolerable. 
 
Thank you! 💖" 

# sends welcome message --------------------------------------------------- 
welcome <- function(bot, update){ 
  escape_username <- str_replace_all(update$message$new_chat_participant$username, 
                                     c("\\*"="\\\\*", "_"="\\\\_")) 
  welcome_message <- paste0('Welcome, ', update$message$new_chat_participant$first_name, 
                            ' (@', escape_username,')! \n\n', welcome_text) 
  
  if (length(update$message$new_chat_participant) > 0L) { 
    bot$sendMessage(chat_id = update$message$chat_id, text = welcome_message, 
                    disable_web_page_preview = T, parse_mode="Markdown") 
  } 
} 

updater <- updater + MessageHandler(welcome, MessageFilters$all) 

# starts bot -------------------------------------------------------------- 
#updater$start_polling()

# get port value ----------------------------------------------------------
PORT <- Sys.getenv(('RSTUDIO_SESSION_PORT'))

# Start the Bot
updater$bot$set_webhook(paste0('https://telegram-bot-rladies.herokuapp.com/',RLadiesRdg))
