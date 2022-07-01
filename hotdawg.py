import discord
from discord import channel
import random

TOKEN = 'OTY5NjkxNDk5MTM2NjkyMjY0.YmxFlQ.HOiRmXrIh_LPaGwy34T3V5n4Qqg'

# intents = discord.Intents.default()
# intents.message_content = True

client = discord.Client()


@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')


@client.event
async def on_message(message):
    if message.author == client.user:
        return

    if message.content.startswith('$hello'):
        await message.channel.send('Hello!')

    if message.content.lower() == '!music_request':
        await message.channel.send(
            'You\'ve requested some tunes, here are the genres: pop, rap, bollywood, kpop, & latin.')

        def check(m):
            if m.content.lower() not in ['pop', 'rap', 'bollywood', 'kpop', 'latin']:
                m.content = 'Please pick a genre from the list.'
                return m.content
            else:
                return m.content.lower() in ['pop', 'rap', 'bollywood', 'kpop', 'latin']
            # return m.content == 'hello' and m.channel == channel
        print('about to make a message')
        # msg = await client.wait_for('message', check=check)

        prompt_answer = 0

        while prompt_answer == 0:
            msg = await client.wait_for('message', check=check)
            song_suggestion = rando_song(msg.content)

            if song_suggestion:
                await message.channel.send(f'Try listening to {song_suggestion[0]}, here: {song_suggestion[1]}')
                prompt_answer += 1
            else:
                await message.channel.send(msg.content)


def rando_song(user_input):
    """
        This is a function that defines a dictionary for each genre and then
        :return: one from each to the main function so they can be given back
        to the user

        it uses random to pick a random key/value and adds to a dictionary

    """
    #  RAP Genre dictionary of song title + link
    rap = {'ROCKSTAR': 'https://www.youtube.com/watch?v=83xBPCw5hh4',
           'The Box': 'https://www.youtube.com/watch?v=uLHqpjW3aDs',
           'Crank That': 'https://www.youtube.com/watch?v=kMBxzoXdKjc',
           'Nevada': 'https://www.youtube.com/watch?v=JfGnwcf5Lt0'}

    # POP Genre dictionary of song title + link
    pop = {'Levitating': 'https://www.youtube.com/watch?v=G2nJPEDc02k',
           'drivers license': 'https://www.youtube.com/watch?v=tNJhkrpLGT8',
           'Blinding Lights': 'https://www.youtube.com/watch?v=fHI8X4OXluQ',
           'Closer': 'https://www.youtube.com/watch?v=Lv6EV478u3U'}

    # BOLLYWOOD Genre dictionary of song title + link
    bollywood = {'Tum Hi Ho': 'https://www.youtube.com/watch?v=VU1B0nkdj-8',
                 'Bajaake Tumba': 'https://www.youtube.com/watch?v=15SpnLnGK4Y',
                 'Tujhe Dekha To': 'https://www.youtube.com/watch?v=7JnKVPtRqVE',
                 'Chaiyya Chaiyya': 'https://www.youtube.com/watch?v=9yGukg6SSZ4'}

    # KPOP Genre dictionary of song title + link
    kpop = {'Butter': 'https://www.youtube.com/watch?v=Uz0PppyT7Cc',
            'Dynamite': 'https://www.youtube.com/watch?v=OiMWFojB9Ok',
            'DNA': 'https://www.youtube.com/watch?v=K6s65ASgMR8',
            'FAKE LOVE': 'https://www.youtube.com/watch?v=NT8ePWlgx_Y'}

    # LATIN Genre dictionary of song title + link
    latin = {'Hips Don\'t Lie': 'https://www.youtube.com/watch?v=H0N-49WBBxk',
             'Despacito': 'https://www.youtube.com/watch?v=72UO0v5ESUo',
             'MIA': 'https://www.youtube.com/watch?v=9UwG87XMKc4',
             'Waka Waka': 'https://www.youtube.com/watch?v=rjJKXxUx2PU'}

    genres = ['rap', 'pop', 'bollywood', 'kpop', 'latin']


    if user_input == 'rap':
        song_list = list(rap.items())
        song_choice = random.choice(song_list)
        print(song_choice)
        return song_choice
    elif user_input == 'pop':
        song_list = list(pop.items())
        song_choice = random.choice(song_list)
        print(song_choice)
        return song_choice
    elif user_input == 'bollywood':
        song_list = list(bollywood.items())
        song_choice = random.choice(song_list)
        print(song_choice)
        return song_choice
    elif user_input == 'kpop':
        song_list = list(kpop.items())
        song_choice = random.choice(song_list)
        print(song_choice)
        return song_choice
    elif user_input == 'latin':
        song_list = list(latin.items())
        song_choice = random.choice(song_list)
        print(song_choice)
        return song_choice





# each print should pick a random key out of the dictionary
# print(random.choice(list(pop)))
#
# print(random.choice(list(rap)))
#
# print(random.choice(list(bollywood)))
#
# print(random.choice(list(kpop)))
#
# print(random.choice(list(latin)))

# @client.event
# async def on_message(message):
#     user_name = str(message.author).split('#')[0]
#     user_msg = str(message.content)
#     channel_name = str(message.channel.name)
#     print(f'{user_name}: {user_msg} ({channel_name})')
#
#     if message.author == client.user:
#         return
#
#     if message.channel.name == 'hotdawgin':
#         if user_msg.lower() == 'hello':
#             await message.channel.send(f'Hello {user_name}')
#             return
#         elif user_msg.lower() == 'bye':
#             await message.channel.send(f'farewell {user_name}!')
#             return
#         elif user_msg.lower() == '!question':
#             response = f'Is a hot dog a Sandwich or a Taco, {user_name}?'
#             await message.channel.send(response)
#             answer = taco_or_sammie()
#
#             # check function (built-in discord func)
#             def check(m):
#                 if m.content.lower() not in ['taco', 'sandwich']:
#                     m.content = f'{user_name}, please answer whether it\'s a taco or a sandwich.'
#                     return m.content
#                 else:
#                     return m.content in ['taco', 'sandwich']
#
#             # msg = await client.wait_for('message', check=check)
#
#             # await message.channel.send(f'{user_name} thinks that a hotdog is a {msg.content} lol')
#             prompt_answer = 0
#
#             while prompt_answer == 0:
#                 msg = await client.wait_for('message', check=check)
#
#                 if msg.content.lower() == answer:
#                     await message.channel.send(f'You\'re gosh darn right, {user_name}. It is!')
#                     prompt_answer += 1
#                     break
#                 elif answer == 'neither':
#                     await message.channel.send(f'Acutally it\'s neither...')
#                     with open('imgs/hot_dog.gif', 'rb') as f:
#                         gif = discord.File(f)
#                         await message.channel.send(file=gif)
#                         prompt_answer += 1
#                     break
#                 elif (msg.content.lower() != answer) and (msg.content.lower() in ['taco', 'sandwich']):
#                     await message.channel.send(f'{user_name}, I\'m sorry but you\'re wrong. A hotdog is a {answer}')
#                     prompt_answer += 1
#                     break
#                 else:
#                     await message.channel.send(msg.content)
#                     continue
#
#
#
# def taco_or_sammie():
#     """
#     This is a function that does the work of determining a response
#     :return: a response for the bot to send to the user
#
#     it: uses random to generate a random number and then checks the number
#     against a conditional to determine the response and every so often posts a gif
#     """
#
#     hotdog_determinator = random.randrange(101)
#     answer = 'filler'
#     if hotdog_determinator <= 40:
#         answer = 'taco'
#         print(answer)
#         return answer
#     elif hotdog_determinator >= 51:
#         answer = 'sandwich'
#         print(answer)
#         return answer
#     elif (hotdog_determinator >= 41) and (hotdog_determinator <= 50):
#         answer = 'neither'
#         print('returned neither')
#         return answer


client.run(TOKEN)
